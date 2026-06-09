package handlers

import (
	"net/http"
	"strconv"

	"disposisi-surat/internal/models"
	"disposisi-surat/internal/repository"

	"github.com/gin-gonic/gin"
)

type DistribusiSMHandler struct {
	distribusiRepo *repository.DistribusiSMRepository
	notifRepo      *repository.NotificationRepository
	actRepo        *repository.ActivityLogRepository
	userRepo       *repository.UserRepository
}

func NewDistribusiSMHandler(
	dist *repository.DistribusiSMRepository,
	n *repository.NotificationRepository,
	a *repository.ActivityLogRepository,
	u *repository.UserRepository,
) *DistribusiSMHandler {
	return &DistribusiSMHandler{
		distribusiRepo: dist,
		notifRepo:      n,
		actRepo:        a,
		userRepo:       u,
	}
}

// ListByUser: guru/staf lihat surat yang didistribusikan Waka ke mereka
func (h *DistribusiSMHandler) ListByUser(c *gin.Context) {
	userID := c.GetInt("user_id")
	list, err := h.distribusiRepo.FindByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Gagal mengambil data"})
		return
	}
	if list == nil {
		list = []models.DistribusiSM{}
	}
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Data: list})
}

// Confirm: guru konfirmasi sudah membaca surat
func (h *DistribusiSMHandler) Confirm(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID := c.GetInt("user_id")

	item, err := h.distribusiRepo.FindByIDForUser(id, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, models.APIResponse{Success: false, Message: "Distribusi tidak ditemukan"})
		return
	}
	if item.Status == "dibaca" || item.Status == "selesai" {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: "Surat sudah dikonfirmasi"})
		return
	}

	if err := h.distribusiRepo.UpdateStatus(id, userID, "dibaca"); err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Gagal konfirmasi"})
		return
	}

	userName := "User"
	if u, err := h.userRepo.FindByID(userID); err == nil {
		userName = u.Nama
	}

	// Notifikasi ke Waka
	if item.IDWaka != nil {
		h.notifRepo.Create(&models.Notification{
			IDPenerima: *item.IDWaka,
			IDPengirim: &userID,
			Judul:      "Surat Dibaca",
			Pesan:      userName + " telah membaca surat: " + item.PerihalSurat,
			Jenis:      "surat_dibaca",
		})
	}

	// Notifikasi ke TU/Admin
	pegawai, _ := h.userRepo.FindByRole("pegawai")
	admins, _ := h.userRepo.FindByRole("admin")
	for _, target := range append(pegawai, admins...) {
		h.notifRepo.Create(&models.Notification{
			IDPenerima: target.ID,
			IDPengirim: &userID,
			Judul:      "Konfirmasi Baca Surat",
			Pesan:      userName + " telah membaca surat: " + item.PerihalSurat,
			Jenis:      "surat_dibaca",
		})
	}

	h.actRepo.Create(&models.ActivityLog{IDUser: userID, Aksi: "KONFIRMASI_BACA", TabelTerkait: "distribusi_sm"})
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Surat berhasil dikonfirmasi"})
}
