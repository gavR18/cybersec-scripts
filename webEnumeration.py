#! /usr/bin/env python3
# Author: GavR
# Date: 2025/09/12
# Version: 1.0
# Description: This script performs network scanning using nmap followed by a web enumeration using dirb if port 80 is open.

import time
import threading
import datetime
import subprocess
import ipaddress
import os

# Validate input is a valid IP address
def validate_ip(TARGET):
    try:
        ipaddress.ip_network(TARGET, strict=False)
        return True
    except ValueError:
        return False

def main():
    # Welcome message
    print("=====================================")  
    print("Welcome to the Web Enumeration Script")
    print("Scan requires correct permissions to run OS detection")
    print("=====================================")  
   
    
    
    # Get user input for target and validate
    while True:
        TARGET = input("\nEnter the target IP address or network: ").strip()
        if validate_ip(TARGET):
            break # Exit if IP is valid
        else:
            print("Invalid IP address. Please try again.")
    # Get user input for output file name and set extensions
    OUTPUT_UFILE = input("Enter the output file name (without extension): ").strip()
    RUN_DATE = datetime.datetime.now().strftime("%Y%m%d")
    OUTPUT_FILE = os.path.splitext(OUTPUT_UFILE)[0] + "_" + RUN_DATE # Remove any existing extension and add date
    FULL_REPORT = f"{OUTPUT_FILE}_full_report_.txt" 
    NMAP_OUTPUT = f"{OUTPUT_FILE}_nmap.nmap"
    GNMAP_OUTPUT = f"{OUTPUT_FILE}_nmap.gnmap"
    DIRB_OUTPUT = f"{OUTPUT_FILE}_dirb.txt"
    print("=====================================")
    print(f"Scanning target {TARGET}, please wait...\n")
    # Start Report
    with open(FULL_REPORT, 'w') as report:
        report.write(f"""
# Web enumeration Scan Report
# Report Started: {RUN_DATE}
# Target: {TARGET}
# Output Files:
    - {FULL_REPORT}
    - {NMAP_OUTPUT}
    - {GNMAP_OUTPUT}
    - {DIRB_OUTPUT}

===== Nmap Scan Results =====
        """)
              
    # nmap scan
    nmap_commands = [
        "nmap",
        "-O",               # OS detection
        "-sV",              # Version detection
        "--open",           # Open ports only
        "-p-",              # Scan all ports
        TARGET,
        "-oN", NMAP_OUTPUT, # Nmap filetype
        "-oG", GNMAP_OUTPUT,# Grepable output (used for Dirb)
    ]
    try:
        # Timer setup
        def live_timer(stop_event):
            start_time = time.time()
            while not stop_event.is_set():
                elapsed = time.time() - start_time
                print(f"\rElapsed time: {elapsed:.1f} seconds", end='', flush=True)
                time.sleep(5)
            print(f"\rScan completed in {elapsed:.1f} seconds{' ' * 20}")
        
        # Start timer
        stop_timer = threading.Event()
        timer_thread = threading.Thread(target=live_timer, args=(stop_timer,))
        timer_thread.start()
        
        # Run nmap
        nmap_result = subprocess.run(nmap_commands, capture_output=True, text=True, timeout=1800)
        
        # Stop timer
        stop_timer.set()
        timer_thread.join()
                
        # Print nmap output to CLI
        print("Running Nmap scan . . . \n")
        print("===== NMAP SCAN RESULTS =====\n")
        print(nmap_result.stdout)
        print(nmap_result.stderr)
        
        # Append results to Full Report
        with open(FULL_REPORT, 'a') as report:
            report.write(f"\nNmap Command: {' '.join(nmap_commands)}\n")
            if nmap_result.stdout:
                report.write(f"\nNmap Output:\n{nmap_result.stdout}\n")
            if nmap_result.stderr:
                report.write(f"\nNmap Errors:\n{nmap_result.stderr}\n")
            report.write("===== END NMAP OUTPUT =====")
        
        # Success namp scan, checks for Port 80 in GNMAP
        if nmap_result.returncode == 0:
            print ("===== Nmap Scan Completed Successfully =====")
            
            with open(GNMAP_OUTPUT, 'r') as gn:
                gnmap_content = gn.read()
                if "80/open" in gnmap_content:
                    print("\nIdentified Service with Port 80 open. Starting Dirb scan . . .\n")
                    
                    # Run dirb scan
                    dirb_result = subprocess.run(["dirb", f"http://{TARGET}", "-o", DIRB_OUTPUT], capture_output=True, text=True, timeout=1800)
                    
                    # Append to Full Report
                    with open(FULL_REPORT, 'a') as report:
                        report.write("===== Dirb Results =====\n")
                        if dirb_result.stdout:
                            report.write(f"\nDirb Output:\n{dirb_result.stdout}\n")
                        if dirb_result.stderr:
                            report.write(f"\nDirb Errors\n{dirb_result.stderr}\n")
                        report.write("===== END DIRB OUTPUT =====")
                else:
                    print("\nPort 80 was not identified as open, Dirb not run")
                    with open(FULL_REPORT, 'a') as report:
                        report.write("===== Port 80 closed, Dirb skipped =====")
        # Nmap fails to run with returned code
        else:
            print(f"\n Nmap scan failed with return code {nmap_result.returncode}")
    
    # Nmap timeout
    except subprocess.TimeoutExpired:
        print("\n++ Nmap Scan Timeout after 30 minutes ++")
    except Exception as e:
        print(f"++ An error has occurred: {e} ")
        
    print("=====================================")
    print("\nScan completed! Results saved to:")
    print(f"  Full Report: {FULL_REPORT}")
    print(f"  Nmap Output: {NMAP_OUTPUT}")
    print(f"  Grepable Output: {GNMAP_OUTPUT}")
    if os.path.exists(DIRB_OUTPUT):
        print(f"  Dirb Output: {DIRB_OUTPUT}")
        
if __name__ == "__main__":
    main()
    
    
                    

    
    

    
                    

    
    
