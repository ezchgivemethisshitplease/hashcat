#!/usr/bin/env bash

# =================================================================
# Hashcat Wordlists Setup Script
# =================================================================
# Downloads required wordlists for hashcat cracking
# Cross-platform: Linux, macOS, *BSD, WSL
# =================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# URLs for wordlists
ROCKRUS_BASE_URL="https://github.com/davidalami/rockrus2022/releases/download/v1.0.0"
ROCKYOU_URL="https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"

# Wordlist files
WORDLISTS=(
    "part_1.txt"
    "part_2.txt"
    "part_3.txt"
    "part_4.txt"
    "part_5.txt"
    "part_6.txt"
    "rockyou.txt"
)

# ==========================
# Helper Functions
# ==========================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

download_file() {
    local url="$1"
    local output="$2"
    
    log_info "Downloading $(basename "$output")..."
    
    if check_command curl; then
        curl -L --progress-bar "$url" -o "$output"
    elif check_command wget; then
        wget --show-progress -O "$output" "$url"
    else
        log_error "Neither curl nor wget found. Please install one."
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Downloaded: $(basename "$output")"
        return 0
    else
        log_error "Failed to download: $(basename "$output")"
        return 1
    fi
}

# ==========================
# Main Setup
# ==========================

main() {
    echo ""
    log_info "Hashcat Wordlists Setup"
    echo "================================================================="
    echo ""
    
    # Check for download tools
    if ! check_command curl && ! check_command wget; then
        log_error "Neither curl nor wget found!"
        log_error "Please install one: brew install curl (macOS) or apt install curl (Linux)"
        exit 1
    fi
    
    # Download part_1 through part_6 from rockrus2022
    log_info "Downloading Russian wordlists (part_1 - part_6) from rockrus2022..."
    echo ""
    
    for i in {1..6}; do
        filename="part_${i}.txt"
        
        if [ -f "$filename" ]; then
            log_warning "$filename already exists, skipping..."
        else
            url="${ROCKRUS_BASE_URL}/${filename}"
            download_file "$url" "$filename" || true
        fi
        echo ""
    done
    
    # Download rockyou.txt
    log_info "Downloading rockyou.txt (classic wordlist)..."
    echo ""
    
    if [ -f "rockyou.txt" ]; then
        log_warning "rockyou.txt already exists, skipping..."
    else
        download_file "$ROCKYOU_URL" "rockyou.txt" || true
    fi
    
    echo ""
    echo "================================================================="
    log_success "Setup complete!"
    echo ""
    log_info "Wordlist statistics:"
    
    # Show downloaded files
    for file in "${WORDLISTS[@]}"; do
        if [ -f "$file" ]; then
            size=$(du -h "$file" | cut -f1)
            lines=$(wc -l < "$file" | tr -d ' ')
            echo "  ✓ $file - $size ($lines passwords)"
        fi
    done
    
    echo ""
    log_info "You can now run hashcat with these wordlists!"
    echo ""
}

# Run main function
main "$@"
