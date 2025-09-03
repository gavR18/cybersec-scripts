#!/bin/bash
echo "========================================================="
echo "Basic Enumeration Script Running"
echo "++ GR Sept 2025 ++"
echo ""

# Check if IP/s Argument #
if [ $# -eq 0 ]; then
  read -p "Enter IP address or range: " TARGET
else
  TARGET=$1
fi

# Validate target input
if [ -z "$TARGET" ]; then
  echo "Error: No target specified"
  read -p "Enter IP address or range: " TARGET
  # Re-validate after second input attempt
  if [ -z "$TARGET" ]; then
    echo "Error: Still no target specified. Exiting."
    exit 1
  fi
fi

# Scan type selection
echo "Select scan types and separate each with a space"
echo "-A    - Aggressive scan"
echo "-sV    - Version detection"
echo "-sS    - SYN stealth scan"
echo "-sT    - TCP connect scan"
echo "-sU    - UDP scan"
echo "--script - NSE script (add script names after)"
echo ""
echo "All nmap options will work."
echo "Example: -sS -sV | -A | -sT --script vuln"
read -p "Enter nmap options: " SCAN_OPTIONS
read -p "Enter file output name: " OUTPUT_FILE

# Validate File Name
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="nmap_scan_$(date +%Y%m%d_%H%M%S).txt"
fi

# Confirm options and proceed or exit
echo "Selected target/s: $TARGET"
echo "Scan Options: $SCAN_OPTIONS"
echo "Output to be saved at: $OUTPUT_FILE"
read -p "Press enter to proceed or Ctrl+C to cancel: " CONFIRMATION

if [ -z "$CONFIRMATION" ]; then
  echo "[+] Scanning $TARGET with options: $SCAN_OPTIONS"
  echo "Output saved in $OUTPUT_FILE"
  {
  echo ""
  echo "========================================================="
  echo "nmap $SCAN_OPTIONS $TARGET"
  echo "Performed on $(date)"
  echo "========================================================="
  nmap $SCAN_OPTIONS $TARGET
  echo "======================== END =============================="
  echo ""
  } >> "$OUTPUT_FILE"
else
  echo "Scan aborted"
  exit 1
fi
