package repository

import (
	"database/sql"
	"disposisi-surat/internal/models"
)

type DistribusiSMRepository struct{ db *sql.DB }

func NewDistribusiSMRepository(db *sql.DB) *DistribusiSMRepository {
	return &DistribusiSMRepository{db: db}
}

func (r *DistribusiSMRepository) Create(d *models.DistribusiSM) error {
	return r.db.QueryRow(
		`INSERT INTO distribusi_sm (id_disposisi, id_user, id_jabatan, status, id_waka, catatan_waka)
		 VALUES ($1, $2, $3, $4, $5, $6) RETURNING id_penerima_disposisi`,
		d.IDDisposisi, d.IDUser, d.IDJabatan, d.Status, d.IDWaka, d.CatatanWaka,
	).Scan(&d.IDPenerimaDisposisi)
}

func (r *DistribusiSMRepository) UpdateStatus(id, userID int, status string) error {
	_, err := r.db.Exec(
		`UPDATE distribusi_sm
		 SET status = $1, read_at = CASE WHEN $1 = 'dibaca' THEN NOW() ELSE read_at END
		 WHERE id_penerima_disposisi = $2 AND id_user = $3`,
		status, id, userID,
	)
	return err
}

func (r *DistribusiSMRepository) FindByIDForUser(id, userID int) (*models.DistribusiSM, error) {
	var ds models.DistribusiSM
	err := r.db.QueryRow(
		`SELECT ds.id_penerima_disposisi, ds.id_disposisi, ds.id_user, ds.id_jabatan,
		        ds.status, ds.read_at, ds.created_at, ds.id_waka, ds.catatan_waka,
		        sm.id_surat_masuk, sm.no_surat, sm.perihal_surat, sm.asal_surat, COALESCE(sm.file_pdf,'')
		 FROM distribusi_sm ds
		 JOIN disposisi d ON ds.id_disposisi = d.id_disposisi
		 JOIN surat_masuk sm ON d.id_surat_masuk = sm.id_surat_masuk
		 WHERE ds.id_penerima_disposisi = $1 AND ds.id_user = $2`,
		id, userID,
	).Scan(
		&ds.IDPenerimaDisposisi, &ds.IDDisposisi, &ds.IDUser, &ds.IDJabatan,
		&ds.Status, &ds.ReadAt, &ds.CreatedAt, &ds.IDWaka, &ds.CatatanWaka,
		&ds.IDSuratMasuk, &ds.NoSurat, &ds.PerihalSurat, &ds.AsalSurat, &ds.FilePDF,
	)
	if err != nil {
		return nil, err
	}
	return &ds, nil
}

func (r *DistribusiSMRepository) FindByUserID(userID int) ([]models.DistribusiSM, error) {
	rows, err := r.db.Query(
		`SELECT ds.id_penerima_disposisi, ds.id_disposisi, ds.id_user, ds.id_jabatan,
		        ds.status, ds.read_at, ds.created_at, ds.id_waka, ds.catatan_waka,
		        sm.id_surat_masuk, sm.no_surat, sm.perihal_surat, sm.asal_surat, COALESCE(sm.file_pdf,'')
		 FROM distribusi_sm ds
		 JOIN disposisi d ON ds.id_disposisi = d.id_disposisi
		 JOIN surat_masuk sm ON d.id_surat_masuk = sm.id_surat_masuk
		 WHERE ds.id_user = $1 AND ds.status NOT IN ('dibaca', 'selesai')
		 ORDER BY ds.created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.DistribusiSM
	for rows.Next() {
		var ds models.DistribusiSM
		if err := rows.Scan(
			&ds.IDPenerimaDisposisi, &ds.IDDisposisi, &ds.IDUser, &ds.IDJabatan,
			&ds.Status, &ds.ReadAt, &ds.CreatedAt, &ds.IDWaka, &ds.CatatanWaka,
			&ds.IDSuratMasuk, &ds.NoSurat, &ds.PerihalSurat, &ds.AsalSurat, &ds.FilePDF,
		); err != nil {
			return nil, err
		}
		list = append(list, ds)
	}
	return list, nil
}