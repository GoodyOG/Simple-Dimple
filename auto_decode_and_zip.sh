#!/bin/bash
# --- TechyChi Mass SHC Decoder & Zipper ---

SOURCE_DIR="$HOME/Simple-Dimple"
DECODED_DIR="$HOME/Simple-Dimple-Decoded"
ZIP_FILE="$HOME/Simple-Dimple-Decoded.zip"
EXTRACTOR="extractSHC.py"

clear
echo -e "\033[0;36m┌─────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[0;33m          TECHYCHI MASS SHC DECODER & ZIPPER          \033[0m"
echo -e "\033[0;36m└─────────────────────────────────────────────────────┘\033[0m"

# 1. Prep the Workspace
echo "[*] Duplicating repository to keep original intact..."
rm -rf "$DECODED_DIR" "$ZIP_FILE"
cp -r "$SOURCE_DIR" "$DECODED_DIR"
cd "$DECODED_DIR" || exit 1

echo "[*] Scanning for SHC binaries..."

# 2. Discovery & Decoding Loop
find . -type f | while read -r target; do
    
    # Check if file is an ELF binary
    if file "$target" | grep -q "ELF"; then
        
        # Detect SHC signature
        if strings "$target" | grep -q "E: neither"; then
            echo "  [+] Decoding: $target"
            
            # Patch the binary using the python script we copied over
            python3 "$EXTRACTOR" "$target" > /dev/null 2>&1
            
            PATCH_FILE="${target}.patch"
            if [ -f "$PATCH_FILE" ]; then
                # Execute patch to dump code and overwrite original
                chmod +x "$PATCH_FILE"
                "$PATCH_FILE" > "${target}.tmp" 2>/dev/null
                
                if [ -s "${target}.tmp" ]; then
                    mv "${target}.tmp" "$target"
                    echo "      [✔] Success"
                else
                    echo "      [\033[0;31m!\033[0m] Failed to dump code"
                    rm -f "${target}.tmp"
                fi
                rm -f "$PATCH_FILE"
            fi
        fi
    fi
done

# 3. Clean up the extractor tools from the final export
echo "[*] Cleaning up workspace..."
rm -f "$EXTRACTOR"
rm -rf .git  # Remove git tracking from the zip so it's purely files

# 4. Zip the directory
echo "[*] Compressing to ZIP..."
cd "$HOME"
zip -rq "$ZIP_FILE" "Simple-Dimple-Decoded/"

echo -e "\033[0;36m───────────────────────────────────────────────────────\033[0m"
echo -e "\033[0;32m[✔] Process Complete!\033[0m"
echo -e " Your fully decoded and zipped repository is located at:"
echo -e " \033[0;33m$ZIP_FILE\033[0m"
