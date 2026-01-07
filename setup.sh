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

# Wordlist directory
LISTS_DIR="lists"

# Wordlist files
WORDLISTS=(
    "part_1.txt"
    "part_2.txt"
    "part_3.txt"
    "part_4.txt"
    "part_5.txt"
    "part_6.txt"
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

    # Create lists directory
    log_info "Creating wordlists directory: ${LISTS_DIR}/"
    mkdir -p "${LISTS_DIR}"
    echo ""

    # Download part_1 through part_6 from rockrus2022
    log_info "Downloading Russian wordlists (part_1 - part_6) from rockrus2022..."
    echo ""

    for i in {1..6}; do
        filename="part_${i}.txt"
        filepath="${LISTS_DIR}/${filename}"

        if [ -f "$filepath" ]; then
            log_warning "$filename already exists, skipping..."
        else
            url="${ROCKRUS_BASE_URL}/${filename}"
            download_file "$url" "$filepath" || true
        fi
        echo ""
    done

    # Clone SecLists repository
    log_info "Cloning SecLists repository (~1.2GB, comprehensive password/fuzzing lists)..."
    echo ""

    if [ -d "${LISTS_DIR}/SecLists" ]; then
        log_warning "SecLists/ directory already exists, skipping..."
    else
        if check_command git; then
            log_info "Cloning SecLists (this may take a few minutes)..."
            git clone --depth 1 https://github.com/danielmiessler/SecLists.git "${LISTS_DIR}/SecLists"

            if [ $? -eq 0 ]; then
                log_success "SecLists cloned successfully!"
            else
                log_error "Failed to clone SecLists. You can manually clone it later:"
                echo "  git clone --depth 1 https://github.com/danielmiessler/SecLists.git ${LISTS_DIR}/SecLists"
            fi
        else
            log_error "git not found! Install git to download SecLists:"
            echo "  macOS: brew install git"
            echo "  Linux: sudo apt install git"
            echo ""
            log_info "Or manually download from: https://github.com/danielmiessler/SecLists"
        fi
    fi

    echo ""
    echo "================================================================="
    log_success "Setup complete!"
    echo ""
    log_info "Wordlist statistics:"

    # Show downloaded files
    for file in "${WORDLISTS[@]}"; do
        filepath="${LISTS_DIR}/${file}"
        if [ -f "$filepath" ]; then
            size=$(du -h "$filepath" | cut -f1)
            lines=$(wc -l < "$filepath" | tr -d ' ')
            echo "  ✓ ${LISTS_DIR}/${file} - $size ($lines passwords)"
        fi
    done

    # Show SecLists info
    if [ -d "${LISTS_DIR}/SecLists" ]; then
        seclists_size=$(du -sh "${LISTS_DIR}/SecLists" 2>/dev/null | cut -f1)
        echo "  ✓ ${LISTS_DIR}/SecLists/ - $seclists_size (comprehensive password/fuzzing collections)"
        echo "    - WiFi-WPA wordlists"
        echo "    - 10M+ leaked passwords"
        echo "    - Language-specific lists"
        echo "    - Default credentials"
    fi

    echo ""
    log_info "You can now run hashcat with wordlists from ${LISTS_DIR}/ directory!"
    echo "Example: ./hashcat -m 22000 hash.hc22000 ${LISTS_DIR}/part_1.txt -w 3"
    echo ""
}

# Run main function
main "$@"
