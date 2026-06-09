package models

import "time"

type DistribusiSM struct {
	IDPenerimaDisposisi int        `json:"id_penerima_disposisi"`
	IDDisposisi         int        `json:"id_disposisi"`
	IDUser              *int       `json:"id_user"`
	IDJabatan           *int       `json:"id_jabatan"`
	ReadAt              *time.Time `json:"read_at"`
	CreatedAt           time.Time  `json:"created_at"`
	Status              string     `json:"status"`
	IDWaka              *int       `json:"id_waka"`
	IDDistribusiParent  *int       `json:"id_distribusi_parent"`
	CatatanWaka         string     `json:"catatan_waka"`
	
	// Join fields
	IDSuratMasuk int    `json:"id_surat_masuk"`
	NoSurat      string `json:"no_surat"`
	PerihalSurat string `json:"perihal_surat"`
	AsalSurat    string `json:"asal_surat"`
	FilePDF      string `json:"file_pdf"`
}