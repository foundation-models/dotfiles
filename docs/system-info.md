# System information

Top-level hardware and OS details for this machine. Useful for setup docs, driver choices, and new-install checklists.

---

## Machine

| Field | Value |
|-------|--------|
| **Manufacturer** | Dell Inc. |
| **Model** | XPS 15 9510 |
| **Version** | Not Specified |

---

## OS & kernel

| Field | Value |
|-------|--------|
| **OS** | Ubuntu 24.04.2 LTS (Noble Numbat) |
| **ID** | ubuntu |
| **Kernel** | 6.17.0-14-generic |

---

## CPU

| Field | Value |
|-------|--------|
| **Model** | 11th Gen Intel® Core™ i7-11800H @ 2.30GHz |
| **Architecture** | x86_64 |
| **Cores / threads** | 8 cores, 16 threads |

---

## Memory

| Field | Value |
|-------|--------|
| **RAM** | 32 GiB (31 GiB reported) |

---

## Graphics

| Device | Description |
|--------|-------------|
| **Integrated** | Intel Tiger Lake-H GT1 [UHD Graphics] |
| **Discrete** | NVIDIA GeForce RTX 3050 Ti Mobile (GA107M) |

---

## Storage

| Device | Size | Model |
|--------|------|--------|
| **nvme0n1** | 953.9 GB | PC SN810 NVMe WDC 1024GB |

Partitions: `nvme0n1p1` (1G), `nvme0n1p2` (952.8G).

---

## Peripherals & buses

- **Wi‑Fi / Bluetooth**: Intel Tiger Lake PCH CNVi WiFi; Intel AX201 Bluetooth (USB)
- **Fingerprint**: Goodix USB2.0 MISC (27c6:63ac)
- **Audio**: Intel Tiger Lake-H HD Audio
- **Card reader**: Realtek RTS5260 PCI Express Card Reader
- **Internal webcam**: Intel IPU6 (MIPI); requires `linux-modules-ipu6-$(uname -r)` on Ubuntu (see [setup-new-desktop.md](setup-new-desktop.md#10-howdy-face-recognition-login))

---

## Notes

- Tiger Lake platform: internal camera uses Intel IPU6 (MIPI), not USB UVC. Install `linux-modules-ipu6-*` for the running kernel; if no `/dev/video*`, check BIOS for Camera / Privacy settings.
- Howdy (face login) is documented in [setup-new-desktop.md](setup-new-desktop.md#10-howdy-face-recognition-login).
