# Riset Solusi eKYC Open-Source — Victoria Sekuritas

Kurasi kandidat open-source & self-hosted untuk OCR KTP, Face Match, Passive Liveness, dan Tanda Tangan (sesuai MASTER_PROMPT). **Angka bintang/last-commit bersifat perkiraan — verifikasi ulang di GitHub sebelum keputusan final.** Semua yang tercantum = **gratis & self-hosted** kecuali disebutkan.

Rekomendasi ringkas (dipakai di `sekuritas-ai`): **PaddleOCR** (OCR) + **InsightFace** (face match) + **Silent-Face-Anti-Spoofing** (liveness) + **signature_pad / package `signature`** (tanda tangan). Semua bisa di-swap via adapter.

---

## 1. OCR KTP
| Repo | Lisensi | Docker | GPU opsional | Prod-ready | Catatan |
|------|---------|--------|--------------|-----------|---------|
| **PaddlePaddle/PaddleOCR** ⭐ | Apache-2.0 | ya | ya | tinggi | Akurasi bagus, dukung banyak bahasa termasuk latin; model ringan (PP-OCRv4). **Pilihan utama.** |
| JaidedAI/EasyOCR | Apache-2.0 | ya | ya | sedang | Mudah dipakai (PyTorch), akurasi baik, agak berat. |
| mindee/doctr | Apache-2.0 | ya | ya | sedang | TF/PyTorch, bagus utk dokumen; komunitas aktif. |
| tesseract-ocr/tesseract | Apache-2.0 | ya | tidak | sedang | Klasik, ringan (CPU), akurasi turun pada foto KTP miring/blur. |
| PaddlePaddle/PaddleOCR (PP-Structure) | Apache-2.0 | ya | ya | sedang | Untuk ekstraksi terstruktur (KV) — parsing field KTP. |
| open-mmlab/mmocr | Apache-2.0 | ya | ya | sedang | Modular, riset-friendly, butuh setup. |
| clovaai/CRAFT-pytorch | MIT | manual | ya | rendah | Text detection saja (dipakai EasyOCR). |
| breezedeus/cnocr | Apache-2.0 | ya | ya | sedang | Fokus CJK+latin, ringan. |
| Belval/TextRecognitionDataGenerator | MIT | — | — | — | Bukan OCR; generator data utk fine-tune. |
| katanaml/sparrow | GPL-3.0 | ya | ya | sedang | Ekstraksi dokumen berbasis LLM/ML (cek lisensi GPL). |

> Untuk KTP Indonesia: jalankan PaddleOCR → kumpulkan baris teks → parse NIK (regex 16 digit), Nama/TTL/Alamat via heuristik layout. Pertimbangkan fine-tune bila akurasi lapangan kurang.

## 2. Face Match (verifikasi wajah)
| Repo | Lisensi | Docker | GPU opsional | Prod-ready | Catatan |
|------|---------|--------|--------------|-----------|---------|
| **deepinsight/insightface** ⭐ | MIT (kode) | ya | ya | tinggi | ArcFace/buffalo_l, akurasi SOTA, embedding utk cek duplikat wajah. **Pilihan utama.** (Cek lisensi model utk komersial.) |
| serengil/deepface | MIT | ya | ya | tinggi | Wrapper mudah (banyak model), cocok cepat integrasi. |
| ageitgey/face_recognition | MIT | ya | ya | sedang | dlib, mudah, akurasi < ArcFace. |
| davidsandberg/facenet | MIT | manual | ya | sedang | FaceNet klasik, agak tua. |
| timesler/facenet-pytorch | MIT | ya | ya | sedang | FaceNet+MTCNN PyTorch, praktis. |
| opencv/opencv (DNN face) | Apache-2.0 | ya | ya | sedang | SFace/YuNet built-in, ringan CPU. |
| exadel-inc/CompreFace | Apache-2.0 | **ya (siap pakai)** | ya | tinggi | **REST API face recognition self-hosted** (docker-compose) — alternatif cepat tanpa koding model. |
| Kagami/go-face | MIT | manual | tidak | sedang | dlib binding Go. |
| cmusatyalab/openface | Apache-2.0 | ya | ya | rendah | Lawas. |
| ZhaoJ9014/face.evoLVe | MIT | manual | ya | sedang | Koleksi model wajah. |

> **CompreFace** menarik bila ingin cepat: REST API siap, tinggal panggil dari adapter. InsightFace bila ingin kontrol penuh + embedding duplikat.

## 3. Passive Liveness / Anti-Spoofing
| Repo | Lisensi | Docker | GPU opsional | Prod-ready | Catatan |
|------|---------|--------|--------------|-----------|---------|
| **minivision-ai/Silent-Face-Anti-Spoofing** ⭐ | Apache-2.0 | manual | ya | sedang | MiniFASNet, ringan, deteksi foto cetak/replay. **Pilihan utama** (ONNX-kan utk deploy). |
| computervisioneng/... face-liveness | MIT | manual | ya | rendah | Contoh edukasi. |
| kprokofi/light-weight-face-anti-spoofing | MIT | manual | ya | sedang | Ringan, cocok mobile/edge. |
| ee09115/spoofing_detection | MIT | manual | ya | rendah | Riset. |
| Faceonlive/Face-Liveness-Detection-SDK | (cek) | ya | ya | sedang | SDK; cek lisensi/komersial. |
| deepinsight/insightface (Anti-spoof) | MIT | ya | ya | sedang | Ada modul anti-spoof di ekosistem. |
| jbhuang0604/... (misc) | — | — | — | — | Verifikasi manual. |
| hairymax/Face-AntiSpoofing | MIT | manual | ya | sedang | Implementasi MiniFAS + demo. |
| Odenktools/... | — | — | — | — | Verifikasi manual. |
| Prox1AI/liveness | (cek) | ya | ya | sedang | Cek lisensi. |

> Untuk liveness **aktif** (gerakan kedip/menoleh), bisa dikombinasikan dengan deteksi landmark (MediaPipe FaceMesh, Apache-2.0) sebagai lapisan tambahan.

## 4. Tanda Tangan Digital (goresan di layar)
| Solusi | Platform | Lisensi | Catatan |
|--------|----------|---------|---------|
| **szimek/signature_pad** ⭐ | Web | MIT | Sudah dipakai di `sekuritas-frontend` (halaman eKYC). |
| **pub.dev `signature`** ⭐ | Flutter | MIT | Sudah dipakai di `sekuritas-mobile` (signature_screen). |
| react-signature-canvas | Web/React | MIT | Alternatif React. |
| fabricjs | Web | MIT | Kanvas umum, bisa utk ttd. |

> Ini **berbeda** dari tanda tangan tersertifikasi (Privy/PSrE) yang memberi kekuatan hukum. Untuk legal, tetap butuh **Privy** (berbayar) — goresan canvas hanya bukti visual.

---

## Catatan deployment (docker-compose)
`docker-compose.yml` saat ini menjalankan model AI dalam **satu service `ekyc-ai`** (FastAPI) — engine OCR/face/liveness dipilih via env (`OCR_ENGINE`, `FACE_MATCH_ENGINE`, `LIVENESS_ENGINE`). Ini **cukup** untuk mayoritas kasus.

Bila ingin **memisah tiap model jadi service sendiri** (skalabilitas/isolasi resource, sesuai MASTER_PROMPT), pecah menjadi mis. `ocr-svc`, `face-svc`, `liveness-svc`, lalu `ekyc-ai` bertindak sebagai orchestrator yang memanggil ketiganya. Trade-off: lebih kompleks & boros RAM. Rekomendasi: **mulai monolit `ekyc-ai`**, pisah hanya bila ada bottleneck nyata.

## Kepatuhan
Untuk eKYC **resmi perbankan/pasar modal**, regulator sering mensyaratkan penyedia tersertifikasi (mis. Dukcapil untuk verifikasi NIK, PSrE untuk tanda tangan). Solusi open-source di atas cocok untuk **MVP/demo/UAT internal** dan sebagai lapisan pra-verifikasi; verifikasi final ke Dukcapil/PSrE mengikuti izin & kontrak klien.
