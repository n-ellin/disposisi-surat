package main

import (
	"log"
	"os"

	"disposisi-surat/internal/config"
	"disposisi-surat/internal/database"
	"disposisi-surat/internal/handlers"
	"disposisi-surat/internal/middleware"
	"disposisi-surat/internal/repository"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  File .env tidak ditemukan, menggunakan env variables")
	}

	cfg := config.Load()
	os.MkdirAll(cfg.UploadDir, 0755)

	db, err := database.Connect(cfg.DSN())
	if err != nil {
		log.Fatal("❌ Gagal koneksi database:", err)
	}
	defer db.Close()

	if err := database.Migrate(db); err != nil {
		log.Fatal("❌ Gagal migrasi:", err)
	}

	if err := database.Seed(db); err != nil {
		log.Fatal("❌ Gagal seed:", err)
	}

	// Runtime patches (sudah di DB, tapi biar aman)
	db.Exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS foto_profil TEXT DEFAULT ''")
	db.Exec("ALTER TABLE notifikasi ADD COLUMN IF NOT EXISTS id_referensi INTEGER")
	db.Exec("ALTER TABLE disposisi ADD COLUMN IF NOT EXISTS isi_disposisi TEXT DEFAULT ''")
	db.Exec("ALTER TABLE disposisi ADD COLUMN IF NOT EXISTS batas_waktu TEXT DEFAULT ''")
	db.Exec("ALTER TABLE disposisi ADD COLUMN IF NOT EXISTS id_jabatan_penerima INTEGER REFERENCES jabatan(id_jabatan)")
	db.Exec("ALTER TABLE distribusi_sm ADD COLUMN IF NOT EXISTS catatan_waka TEXT")

	// Fix notifikasi constraint
	db.Exec("ALTER TABLE notifikasi DROP CONSTRAINT IF EXISTS notifikasi_jenis_check")
	db.Exec(`ALTER TABLE notifikasi ADD CONSTRAINT notifikasi_jenis_check CHECK (
		jenis IN ('surat_masuk_baru','surat_keluar_baru','surat_disetujui','surat_ditolak',
		'surat_masuk_dikonfirmasi','surat_keluar_dikonfirmasi','permintaan_persetujuan_akun',
		'review_surat','surat_diteruskan','disposisi_diterima','surat_didistribusikan','surat_dibaca')
	)`)

	// Repositories
	userRepo := repository.NewUserRepository(db)
	smRepo := repository.NewSuratMasukRepository(db)
	skRepo := repository.NewSuratKeluarRepository(db)
	dispRepo := repository.NewDisposisiRepository(db)
	distribusiRepo := repository.NewDistribusiSMRepository(db)
	notifRepo := repository.NewNotificationRepository(db)
	actRepo := repository.NewActivityLogRepository(db)
	otpRepo := repository.NewOTPRepository(db)

	// Handlers
	authHandler := handlers.NewAuthHandler(cfg, userRepo, otpRepo, actRepo)
	userHandler := handlers.NewUserHandler(userRepo, actRepo)
	smHandler := handlers.NewSuratMasukHandler(cfg, smRepo, dispRepo, notifRepo, actRepo, userRepo)
	skHandler := handlers.NewSuratKeluarHandler(cfg, skRepo, notifRepo, actRepo, userRepo)
	profileHandler := handlers.NewProfileHandler(cfg, userRepo, otpRepo, actRepo)
	dispHandler := handlers.NewDisposisiHandler(dispRepo, notifRepo, actRepo, userRepo)
	wakaHandler := handlers.NewWakaHandler(smRepo, dispRepo, distribusiRepo, notifRepo, actRepo, userRepo)
	distribusiHandler := handlers.NewDistribusiSMHandler(distribusiRepo, notifRepo, actRepo, userRepo)
	notifHandler := handlers.NewNotificationHandler(notifRepo)
	actHandler := handlers.NewActivityHandler(actRepo)
	dashHandler := handlers.NewDashboardHandler(smRepo, skRepo, userRepo, dispRepo)

	r := gin.Default()
	r.Use(middleware.CORSMiddleware())
	r.Static("/uploads", cfg.UploadDir)

	api := r.Group("/api")
	{
		// Public
		api.POST("/auth/login", authHandler.Login)
		api.POST("/auth/forgot-password", authHandler.ForgotPassword)
		api.POST("/auth/resend-otp", authHandler.ResendOTP)
		api.POST("/auth/verify-otp", authHandler.VerifyOTP)
		api.POST("/auth/reset-password", authHandler.ResetPassword)

		// Protected
		auth := api.Group("")
		auth.Use(middleware.AuthMiddleware(cfg))
		{
			auth.POST("/auth/refresh", authHandler.RefreshToken)
			auth.GET("/auth/me", authHandler.GetMe)

			// Dashboard
			auth.GET("/dashboard/stats", dashHandler.Stats)

			// Profile
			auth.GET("/profile", profileHandler.Get)
			auth.PUT("/profile", profileHandler.Update)
			auth.PUT("/profile/password", profileHandler.ChangePassword)
			auth.POST("/profile/photo", profileHandler.UploadPhoto)
			auth.DELETE("/profile/photo", profileHandler.DeletePhoto)
			auth.PUT("/profile/switch-jabatan", profileHandler.SwitchJabatan)
			auth.POST("/profile/send-otp", authHandler.SendOTPForPasswordChange)

			// Notifications
			auth.GET("/notifications", notifHandler.List)
			auth.GET("/notifications/unread-count", notifHandler.UnreadCount)
			auth.PUT("/notifications/:id/read", notifHandler.MarkAsRead)
			auth.PUT("/notifications/read-all", notifHandler.MarkAllAsRead)

			// Users (accessible by admin, kepsek, pegawai, waka)
			auth.GET("/users", userHandler.ListByRole)

			// Users management (admin only)
			admin := auth.Group("")
			admin.Use(middleware.RequireRole("admin"))
			{
				admin.GET("/users/:id", userHandler.GetByID)
				admin.POST("/users", userHandler.Create)
				admin.PUT("/users/:id", userHandler.Update)
				admin.DELETE("/users/:id", userHandler.Delete)
				admin.GET("/activity-logs", actHandler.List)
			}

			// Surat Masuk
			auth.GET("/surat-masuk/history", smHandler.ListHistory)
			auth.GET("/surat-masuk", smHandler.List)
			auth.GET("/surat-masuk/:id", smHandler.GetByID)

			// TU only
			tu := auth.Group("")
			tu.Use(middleware.RequireRole("admin", "pegawai"))
			{
				tu.POST("/surat-masuk", smHandler.Create)
				tu.PUT("/surat-masuk/:id", smHandler.Update)
				tu.PUT("/surat-masuk/:id/teruskan-waka", smHandler.ForwardToWaka) // NEW: TU pilih Waka
				tu.PUT("/surat-masuk/:id/arsip", smHandler.Archive)
				tu.DELETE("/surat-masuk/:id", smHandler.Delete)
			}

			// Kepsek
			kepsek := auth.Group("")
			kepsek.Use(middleware.RequireRole("kepsek"))
			{
				kepsek.PUT("/surat-masuk/:id/review", smHandler.Review)
				kepsek.PUT("/surat-keluar/:id/review", skHandler.Review)
			}

			// Waka
			waka := auth.Group("")
			waka.Use(middleware.RequireRole("waka"))
			{
				waka.GET("/waka/surat-masuk", wakaHandler.ListSurat)
				waka.POST("/waka/distribusi", wakaHandler.Distribusi)
			}

			// Surat Keluar
			auth.GET("/surat-keluar/history", skHandler.ListHistory)
			auth.GET("/surat-keluar", skHandler.List)
			auth.GET("/surat-keluar/:id", skHandler.GetByID)

			tuKeluar := auth.Group("")
			tuKeluar.Use(middleware.RequireRole("admin", "pegawai"))
			{
				tuKeluar.POST("/surat-keluar", skHandler.Create)
				tuKeluar.PUT("/surat-keluar/:id", skHandler.Update)
				tuKeluar.PUT("/surat-keluar/:id/arsip", skHandler.Archive)
				tuKeluar.DELETE("/surat-keluar/:id", skHandler.Delete)
			}

			// Disposisi (legacy)
			auth.GET("/disposisi", dispHandler.ListByUser)
			auth.PUT("/disposisi/:id/confirm", dispHandler.Confirm)

			// Distribusi SM (guru menerima surat dari Waka)
			auth.GET("/distribusi-sm", distribusiHandler.ListByUser)
			auth.PUT("/distribusi-sm/:id/confirm", distribusiHandler.Confirm)
		}
	}

	log.Printf("🚀 Server berjalan di port %s\n", cfg.ServerPort)
	if err := r.Run(":" + cfg.ServerPort); err != nil {
		log.Fatal("❌ Gagal menjalankan server:", err)
	}
}