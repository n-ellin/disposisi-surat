package handlers

import (
	"net/http"
	"strconv"

	"disposisi-surat/internal/models"
	"disposisi-surat/internal/repository"

	"github.com/gin-gonic/gin"
)

type WakaHandler struct {
	smRepo       *repository.SuratMasukRepository
	dispRepo     *repository.DisposisiRepository
	distribusiRepo *repository.DistribusiSMRepository
	notifRepo    *repository.NotificationRepository
	actRepo      *repository.ActivityLogRepository
	userRepo     *repository.UserRepository
}

func NewWakaHandler(sm *repository.SuratMasukRepository, d *repository.DisposisiRepository, dist *repository.DistribusiSMRepository, n *repository.NotificationRepository, a *repository.ActivityLogRepository, u *repository.UserRepository) *WakaHandler {
	return &WakaHandler{smRepo: sm, dispRepo: d, distribusiRepo: dist, notifRepo: n, actRepo: a, userRepo: u}
}

// ListSurat: Waka lihat surat yang didisposisi ke dia
func (h *WakaHandler) ListSurat(c *gin.Context) {
	wakaID := c.GetInt("user_id")
	
	list, err := h.smRepo.FindByWakaID(wakaID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Gagal mengambil data"})
		return
	}
	if list == nil {
		list = []models.SuratMasuk{}
	}
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Data: list})
}

// Distribusi: Waka kirim surat ke multiple user (guru)
func (h *WakaHandler) Distribusi(c *gin.Context) {
	var req struct {
		IDSuratMasuk int    `json:"id_surat_masuk"`
		TujuanIDs    []int  `json:"tujuan_ids"`
		CatatanWaka  string `json:"catatan_waka"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: "Data tidak valid"})
		return
	}

	wakaID := c.GetInt("user_id")

	// Validasi: surat harus sudah disetujui kepsek dan didisposisi ke waka ini
	surat, err := h.smRepo.FindByID(req.IDSuratMasuk)
	if err != nil {
		c.JSON(http.StatusNotFound, models.APIResponse{Success: false, Message: "Surat tidak ditemukan"})
		return
	}
	if surat.StatusVerifikasi != "disetujui" {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: "Surat belum disetujui Kepsek"})
		return
	}

	// Get disposisi aktif untuk dapatkan catatan kepsek
	disposisiList, _ := h.dispRepo.FindBySuratMasukID(req.IDSuratMasuk)
	var catatanKepsek string
	for _, d := range disposisiList {
		if d.CatatanKepsek != "" {
			catatanKepsek = d.CatatanKepsek
			break
		}
	}
	if catatanKepsek == "" {
		catatanKepsek = "-"
	}

	// Create distribusi untuk setiap user
	dispID := 0
	if surat.IDDisposisiAktif != nil {
		dispID = *surat.IDDisposisiAktif
	}

	for _, userID := range req.TujuanIDs {
		// Insert ke distribusi_sm
		err := h.distribusiRepo.Create(&models.DistribusiSM{
			IDDisposisi: dispID,
			IDUser:       &userID,
			IDWaka:       &wakaID,
			Status:       "belum_dibaca",
			CatatanWaka:  req.CatatanWaka,
		})
		if err != nil {
			continue
		}

		// Notifikasi ke user
		h.notifRepo.Create(&models.Notification{
			IDPenerima:    userID,
			IDPengirim:    &wakaID,
			Judul:         "Surat Baru Untuk Anda",
			Pesan:         "Anda menerima surat: " + surat.PerihalSurat,
			Jenis:         "disposisi_diterima",
			TipeReferensi: "surat_masuk",
			IDReferensi:   &req.IDSuratMasuk,
		})
	}

	// Update status alur
	h.smRepo.UpdateStatusAlur(req.IDSuratMasuk, "didistribusikan_waka")

	h.actRepo.Create(&models.ActivityLog{IDUser: wakaID, Aksi: "DISTRIBUSI_WAKA", TabelTerkait: "distribusi_sm"})
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Surat berhasil didistribusikan ke " + strconv.Itoa(len(req.TujuanIDs)) + " penerima"})
}