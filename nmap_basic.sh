#!/bin/bash
echo "========================================================="
echo "Basic Enumeration Script Running"
echo "++ GR Sept 2025 ++"
echo ""

# Initiatlising Variables
SEARCHSPLOIT_REQ="N"


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

# Validate File Name and Create XML file name
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="nmap_scan_$(date +%Y%m%d_%H%M%S).txt"
  XML_FILE="${OUTPUT_FILE%.*}.xml"
else
  OUTPUT_FILE="${OUTPUT_FILE%.*}.txt"
  XML_FILE="${OUTPUT_FILE%.*}.xml"
fi

# Check for SCAN_OPTIONS for Version Check, Ask for Searchsploit
if [[ "$SCAN_OPTIONS" == *"-sV"* ]] || [[ "$SCAN_OPTIONS" == *"-A"* ]]; then
  read -p "Do you want Searchsploit Results [Y/N]? " SEARCHSPLOIT_REQ
  if [[ "${SEARCHSPLOIT_REQ^^}" == "Y" ]]; then
    SEARCHSPLOIT_REQ="Y"
    echo "Searchsploit will be utilised"
  else
    SEARCHSPLOIT_REQ="N"
    echo "Searchsploit will not be utilised"
  fi
fi

# Confirm options and proceed or exit
echo ""
echo "========================================================="
echo ""
echo "Selected target/s: $TARGET"
echo ""
echo "Scan Options: $SCAN_OPTIONS"
echo ""
echo "Output to be saved at: $OUTPUT_FILE"
echo ""
read -p "Press enter to proceed or Ctrl+C to cancel: " CONFIRMATION
echo ""
echo "========================================================="

if [ -z "$CONFIRMATION" ]; then
  echo ""
  echo "========================================================="
  echo "[+] Scanning $TARGET with options: $SCAN_OPTIONS"
  echo "Please wait...."
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

if [ "$SEARCHSPLOIT_REQ" = "Y" ]; then
  echo "=========================================================="
  echo "nmap XML file created and Searchsploit Scan commencing" 
  
  ## Create an xml file output.
  ## Future use, pair with searchsploit nmap [host] -sV -oX file.xml
  nmap $TARGET -sV -oX "$XML_FILE"
  
  
  {
  echo ""
  echo "========================================================="
  echo "Searchsploit Results for $OUTPUT_FILE on Targets: $TARGET"
  echo "Generated on $(date)"
  echo "========================================================="
  searchsploit --nmap "$XML_FILE"
  echo "======================== END =============================="
  echo ""
  } >> "${OUTPUT_FILE%.*}_Searchsploit.txt"
  
fi

# Confirmation complete
echo ""
echo "[+] Scan completed and report saved to $OUTPUT_FILE"
echo ""
if [ "$SEARCHSPLOIT_REQ" = "Y" ]; then
  echo "[+] Searchsploit completed and report saved to ${OUTPUT_FILE%.*}_Searchsploit.txt"
  echo ""
fi

