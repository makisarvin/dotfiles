 ### 1. CUPS admin login & missing lpadmin group                                                                                                                                
                                                                                                                                                                                
 Arch Linux doesn't use a lpadmin group by default. Omarchy/Arch configures CUPS to use the sys and root groups for admin access, but your user account is only in wheel. The   
 active cups-files.conf had been changed from the default and was missing wheel.                                                                                                
                                                                                                                                                                                
 Fix applied: I added wheel back to the SystemGroup line in /etc/cups/cups-files.conf and restarted CUPS:                                                                       
                                                                                                                                                                                
 ```bash                                                                                                                                                                        
   pkexec bash -c 'sed -i "s/^SystemGroup.*/SystemGroup cups-browsed sys root wheel/" /etc/cups/cups-files.conf && systemctl restart cups'                                      
 ```                                                                                                                                                                            
                                                                                                                                                                                
 You can now log in to https://localhost:631/admin with your normal username and password (the same ones you use for sudo).                                                     
                                                                                                                                                                                
 ### 2. hp-setup -i failing to discover the printer                                                                                                                             
                                                                                                                                                                                
 hp-setup relies on HP-specific discovery protocols that often fail to detect WiFi printers (especially if the printer is in sleep/energy-save mode). However, your printer is  
 visible on the network via standard mDNS/AirPrint.                                                                                                                             
                                                                                                                                                                                
 I found it broadcasting at:                                                                                                                                                    
 - IP: 192.168.1.93                                                                                                                                                             
 - URI: ipps://HP%20LaserJet%20MFP%20M227fdw%20(8ECE4C)._ipps._tcp.local/                                                                                                       
                                                                                                                                                                                
 ### 3. Printer not showing up in Omarchy / CUPS                                                                                                                                
                                                                                                                                                                                
 Since CUPS had no queues configured, nothing showed up in applications or the desktop. I added the printer directly using the modern IPP Everywhere (driverless) protocol — no 
 proprietary plugin needed:                                                                                                                                                     
                                                                                                                                                                                
 ```bash                                                                                                                                                                        
   pkexec lpadmin -p HP-LaserJet-M227fdw -E \                                                                                                                                   
     -v "ipps://HP%20LaserJet%20MFP%20M227fdw%20(8ECE4C)._ipps._tcp.local/" \                                                                                                   
     -m everywhere                                                                                                                                                              
                                                                                                                                                                                
   pkexec lpadmin -d HP-LaserJet-M227fdw                                                                                                                                        
 ```                                                                                                                                                                            
                                                                                                                                                                                
 Current status:                                                                                                                                                                
                                                                                                                                                                                
 ```text                                                                                                                                                                        
   printer HP-LaserJet-M227fdw is idle.  enabled since Sat 19 Sep 2026 01:34:28 PM PDT                                                                                          
   system default destination: HP-LaserJet-M227fdw                                                                                                                              
 ```                                                                                                                                                                            
                                                                                                                                                                                
 The printer is now configured as the system default and should appear in Omarchy's print dialogs.                                                                              
                                                                                                                                                                                
 ### What you should do now                                                                                                                                                     
                                                                                                                                                                                
 1. Test printing: Open any application and try to print, or go to https://localhost:631/printers/HP-LaserJet-M227fdw and click "Print Test Page".                              
 2. If you need scanning (since it's an MFP), the easiest modern way on Arch is:                                                                                                
    ```bash                                                                                                                                                                     
      sudo pacman -S sane-airscan                                                                                                                                               
    ```                                                                                                                                                                         
    Then use your favorite scanning app (e.g. Document Scanner, Simple Scan, or scanimage -L). The sane-airscan backend uses the same AirPrint protocol the printer already     
    broadcasts.                                                                                                                                                                 
 3. If you specifically need hp-setup for HP-specific tools (e.g. hp-toolbox for supply levels), run it with the IP address directly:                                           
    ```bash                                                                                                                                                                     
      sudo hp-setup -i 192.168.1.93                                                                                                                                             
    ```                                                                                                                                                                         
                                                                                                                                                                                
 Everything is ready to print. Let me know if the test page works or if you run into any other issues!  
