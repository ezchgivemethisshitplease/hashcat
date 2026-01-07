# Hashcat Portable Setup

Portable hashcat configuration with Russian wordlists for WiFi cracking.

## Quick Start

### 1. Clone Repository
```bash
git clone <your-repo-url> hashcat
cd hashcat
```

### 2. Build Hashcat (Platform-specific)
```bash
make
```

**Supported platforms:** Linux, macOS, Windows (MSYS2/WSL), FreeBSD

### 3. Download Wordlists
```bash
./setup.sh
```

This will download:
- `part_1.txt` - `part_6.txt` (120M Russian passwords)
- `rockyou.txt` (14M classic passwords)
- `SecLists/` (~1.2GB comprehensive password/fuzzing collections)

### 4. Run Hashcat
```bash
./hashcat -m 22000 capture.hc22000 part_1.txt -r rules/best66.rule -w 3
```

---

## Cross-Platform Compatibility

### ✅ What Works Everywhere (Portable)

| Component | Description | Platform |
|-----------|-------------|----------|
| **Source code** | C/OpenCL/Metal sources | All |
| **Rules** | `rules/*.rule` | All |
| **Wordlists** | `part_*.txt`, `rockyou.txt` | All |
| **Masks** | `masks/*.hcmask` | All |
| **Charsets** | `charsets/*.hcchr` | All |
| **Configuration** | Hash files, potfiles (if copied) | All |

### ❌ What Doesn't Work (Must Rebuild)

| Component | Reason | Solution |
|-----------|--------|----------|
| **`hashcat` binary** | Platform-specific executable | Run `make` |
| **`obj/` directory** | Compiled objects | Ignored in git, auto-rebuilt |
| **`kernels/` cache** | Compiled GPU kernels | Auto-generated on first run |
| **Libraries** | `.so` (Linux), `.dylib` (macOS), `.dll` (Win) | Built with `make` |

---

## Platform-Specific Build Instructions

### macOS (Apple Silicon / Intel)
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Build hashcat
make

# Metal backend will be used automatically (best performance)
./hashcat -I  # Check devices
```

**Performance note:** Use Metal backend (`-d 1`) for M1/M2/M3 chips.

### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt update
sudo apt install build-essential opencl-headers ocl-icd-opencl-dev

# Build hashcat
make

# Check OpenCL devices
./hashcat -I
```

### Windows (MSYS2 recommended)
```bash
# Install MSYS2, then:
pacman -S base-devel mingw-w64-x86_64-toolchain

# Build hashcat
make

# Use with NVIDIA/AMD drivers
./hashcat.exe -I
```

### WSL (Windows Subsystem for Linux)
```bash
# Follow Linux instructions
# GPU passthrough requires WSL2 + NVIDIA/AMD drivers

make
./hashcat -I
```

---

## Repository Structure

```
hashcat/
├── setup.sh              # Wordlist downloader (cross-platform)
├── .gitignore            # Excludes binaries, wordlists, runtime files
├── SETUP_README.md       # This file
│
├── src/                  # Hashcat source code (portable)
├── OpenCL/               # OpenCL kernels (portable)
├── rules/                # Password rules (portable)
├── masks/                # Mask files (portable)
├── charsets/             # Character sets (portable)
│
├── hashcat               # Binary (EXCLUDED - build with `make`)
├── obj/                  # Build artifacts (EXCLUDED - auto-generated)
├── kernels/              # GPU kernel cache (EXCLUDED - auto-generated)
│
└── part_*.txt            # Wordlists (EXCLUDED - download with ./setup.sh)
    rockyou.txt
```

---

## Workflow Example: Clone to New Machine

### Scenario: Clone to Linux Server

```bash
# 1. Clone repo
git clone https://github.com/youruser/hashcat-portable.git
cd hashcat-portable

# 2. Build hashcat for Linux
make

# 3. Download wordlists
./setup.sh

# 4. Run attack
./hashcat -m 22000 myhash.hc22000 part_1.txt -r rules/best66.rule -w 3
```

**Total time:** ~5 minutes (2 min build + 3 min wordlist download)

---

## Why This Approach?

### Traditional Problem:
❌ Commit 1.5GB wordlists → slow clone, huge repo  
❌ Commit binaries → doesn't work on other OS  
❌ Manual setup → easy to forget steps  

### This Solution:
✅ Repo size: ~50MB (sources only)  
✅ Fast clone: ~30 seconds  
✅ Automated setup: `./setup.sh`  
✅ Platform-agnostic: works everywhere  

---

## Wordlist Sources

- **part_1.txt - part_6.txt:** [rockrus2022](https://github.com/davidalami/rockrus2022/releases/tag/v1.0.0) (120M Russian passwords, sorted by frequency)
- **rockyou.txt:** Classic leaked password list (14M entries)
- **SecLists:** [danielmiessler/SecLists](https://github.com/danielmiessler/SecLists) (~1.2GB comprehensive collections)
  - WiFi-WPA specific wordlists (top 4800)
  - 10M+ leaked passwords (Gmail, various databases)
  - Language-specific lists (Dutch, Chinese, German, Polish, etc.)
  - Default router/device credentials
  - Fuzzing payloads and usernames

---

## Tips & Tricks

### Speed up brute-force with GPU prioritization
```bash
# Use optimized kernel (if available)
./hashcat -m 22000 hash.hc22000 wordlist.txt -O -w 3

# Force Metal on macOS (M-series chips)
./hashcat -m 22000 hash.hc22000 wordlist.txt -d 1 -w 3
```

### Check GPU temperature
```bash
./hashcat -m 22000 hash.hc22000 wordlist.txt --hwmon-temp-abort=90
```

### Resume interrupted session
```bash
# Hashcat auto-creates hashcat.restore
./hashcat --restore
```

---

## Troubleshooting

### `clCreateProgramWithBinary(): CL_INVALID_VALUE`
**Solution:** Remove `-O` flag or clear kernel cache:
```bash
rm -rf kernels/
./hashcat ...  # Kernels will rebuild
```

### `Metal API skipped`
**macOS M-series:** Force Metal backend:
```bash
./hashcat -m 22000 hash.hc22000 wordlist.txt -d 1
```

### Wordlist not found
```bash
# Re-run setup script
./setup.sh

# Or manually download
curl -L -O https://github.com/davidalami/rockrus2022/releases/download/v1.0.0/part_1.txt
```

---

## License

Hashcat is licensed under the MIT License. See original `README.md` for details.

This setup configuration is provided as-is for educational and authorized penetration testing purposes only.

---

**Last Updated:** 07/Jan/2026
