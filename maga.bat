:: Assumptions:
::  Drive is mounted on E:
::	[root]\maga\maga.pl
::	[root]\maga\input\registry
::	[root]\maga\input\CustomDestinations
::	[root]\maga\input\AutomaticDestinations
::	- One folder with:
::		- All registry files (registry)
::		- All prefetch files (prefetch)
::		- subfolder with CustomDestinations (custom_destinations)
::		- subfolder with AutomaticDestinations (automatic_destinations)
::	- Tools live here:
::		- C:\Forensic Program Files\Registry Tools\Registry Ripper\rip.exe (registry)
:: Outputs:
::	[root]\maga\output\
::	- Output folder with:
::		- Registry subfolder [DONE]
::		- Jumplist folder [DONE]
::		- Prefetch folder [DONE]
::		- USB folder
::
@ECHO OFF

::Set target user
SET target_user=Donald

::Root level
SET start_dir=C:\cases\maga
SET run_log_file=%start_dir%\run_log.txt
SET error_log_file=%start_dir%\error_log.txt

::Input/output folders
SET input_dir=C:\cases\maga\input
SET output_dir=C:\cases\maga\output

:: Registry Folders
SET registry_input_dir=%input_dir%\registry
SET registry_output_dir=%output_dir%\registry
SET regripper_dir="C:\Forensic Program Files\Registry Tools\Registry Ripper 2.8"

:: Prefetch Folders
SET prefetch_input_dir=%input_dir%\prefetch
SET prefetch_output_dir=%output_dir%\prefetch

:: Jumplist Folders
SET auto_dest_input_dir=%input_dir%\automatic_destinations
SET cust_dest_input_dir=%input_dir%\custom_destinations
SET jumplist_output_dir=%output_dir%\jumplist

:: USB Folders
SET usb_output_dir=%output_dir%\usb

:: SBAG Folders
SET sbag_output_dir=%output_dir%\sbag

ECHO ===Starting new MAGA run=== >> %run_log_file%

ECHO.
ECHO    _____      _____    ________    _____   
ECHO   /     \    /  _  \  /  _____/   /  _  \  
ECHO  /  \ /  \  /  /_\  \/   \  ___  /  /_\  \ 
ECHO /    Y    \/    !    \    \_\  \/    !    \
ECHO \____!__  /\____!__  /\______  /\____!__  /
ECHO         \/         \/        \/         \/ 
ECHO.

:: Need to remove output dir
ECHO Removing output dir to rebuild >> %run_log_file%
IF EXIST %output_dir% (
	RMDIR /S /Q %output_dir%
)
MKDIR %output_dir%

:: Need to create output dirs
ECHO Creating output folders >> %run_log_file%
MKDIR %jumplist_output_dir%
MKDIR %prefetch_output_dir%
MKDIR %registry_output_dir%
MKDIR %sbag_output_dir%
MKDIR %usb_output_folder%

:: Find out where we're mounted
ECHO.
SET /p target_drive="Which drive is the forensic image on? (i.e. E:\): "
ECHO Working from mounted image on: %target_drive% 
ECHO Hope this is correct...
PAUSE

::Copy Registry hives
REM ECHO Copying registry fies to input dir >> %run_log_file%
REM ECHO Grabbing registry files
REM CD %registry_input_dir%
REM DEL /Q *
REM COPY %target_drive%[root]\Users\%target_user%\NTUSER.DAT .
REM COPY %target_drive%[root]\Users\%target_user%\AppData\Local\Microsoft\Windows\UsrClass.dat .
REM COPY %target_drive%[root]\Windows\System32\Config\DEFAULT .
REM COPY %target_drive%[root]\Windows\System32\Config\SAM .
REM COPY %target_drive%[root]\Windows\System32\Config\SECURITY .
REM COPY %target_drive%[root]\Windows\System32\Config\SOFTWARE .
REM COPY %target_drive%[root]\Windows\System32\Config\SYSTEM .

::Do SBAG work while we're here
REM IF EXIST UsrClass.dat (
	REM ECHO "Ripping shellbags from %registry_input_dir%\UsrClass.dat" >> %run_log_file%
	REM sbag UsrClass.dat -base10 -csv -timeformat hh:mm:ss -no_whitespace > %sbag_output_dir%\sbag.csv
REM ) ELSE (
	REM ECHO %registry_input_dir%\UsrClass.dat not found for shellbags >> %run_log_file%
REM )

::Do RegRipper Work
REM ECHO Entering RegRipper Directory: %regripper_dir%
REM CD %regripper_dir%
REM IF EXIST %registry_input_dir%\NTUSER.DAT (
	REM ECHO "Ripping NTUSER.DAT from %registry_input_dir%\NTUSER.DAT" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\NTUSER.DAT -f ntuser > %registry_output_dir%\ntuser.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\NTUSER.DAT not found >> %run_log_file%
REM )

REM IF EXIST %registry_input_dir%\SYSTEM (
	REM ECHO "Ripping SYSTEM from %registry_input_dir%\SYSTEM" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\SYSTEM -f system > %registry_output_dir%\system.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\SYSTEM not found >> %run_log_file%
REM )

REM IF EXIST %registry_input_dir%\SOFTWARE (
	REM ECHO "Ripping SOFTWARE from %registry_input_dir%\SOFTWARE" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\SOFTWARE -f software > %registry_output_dir%\software.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\SOFTWARE not found >> %run_log_file%
REM )

REM IF EXIST %registry_input_dir%\SECURITY (
	REM ECHO "Ripping SECURITY from %registry_input_dir%\SECURITY" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\SECURITY -f security > %registry_output_dir%\security.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\SECURITY not found >> %run_log_file%
REM )

REM IF EXIST %registry_input_dir%\SAM (
	REM ECHO "Ripping SAM from %registry_input_dir%\SAM" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\SAM -f sam > %registry_output_dir%\sam.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\SAM not found >> %run_log_file%
REM )

REM IF EXIST %registry_input_dir%\UsrClass.dat (
	REM ECHO "Ripping UsrClass.dat from %registry_input_dir%\UsrClass.dat" >> %run_log_file%
	REM rip.exe -r %registry_input_dir%\UsrClass.dat -f usrclass > %registry_output_dir%\usrclass.txt
REM ) ELSE (
	REM ECHO %registry_input_dir%\UsrClass.dat not found >> %run_log_file%
REM )

::Prefetch Work
REM ECHO Entering Prefetch Dir: %prefetch_input_dir%
REM CD %prefetch_input_dir%
REM ::Clear out directory
REM DEL /Q *.pf
REM ::Assuming E:\[root]\Windows\Prefetch\*.pf for prefetch
REM COPY %target_drive%[root]\Windows\Prefetch\*.pf .
REM DIR
REM ECHO "Ripping Prefetch from %prefetch_input_dir%" >> %run_log_file%
REM DIR *.pf /b | pf -pipe -csvl2t -timeformat hh:mm:ss -no_whitespace > %prefetch_output_dir%\prefetch-all.csv

:: Jumplist Work
REM ECHO Entering Automatic Destination Dir: %auto_dest_input_dir%
REM CD %auto_dest_input_dir%
REM ::Clear out directory
REM DEL /Q *ions-ms
REM ::Assuming E:\[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations for prefetch
REM COPY %target_drive%[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\*ions-ms .
REM DIR *ions-ms /b | jmp -pipe -csv -base10 -timeformat hh:mm:ss -no_whitespace > %jumplist_output_dir%\jump-auto.csv

:: Jumplist Work
REM ECHO Entering Custom Destination Dir: %cust_dest_input_dir%
REM CD %cust_dest_input_dir%
REM ::Clear out directory
REM DEL /Q *ions-ms
REM ::Assuming E:\[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations for prefetch
REM COPY %target_drive%[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\*ions-ms .
REM DIR *ions-ms /b | jmp -pipe -csv -base10 -timeformat hh:mm:ss -no_whitespace > %jumplist_output_dir%\jump-custom.csv

::Copy USB files
ECHO Copying files needed for USBDevice Forensics to %usb_output_dir%. Please run that tool!
ECHO Copying USB fies to output dir >> %run_log_file%
CD %usb_output_dir%
COPY %target_drive%[root]\Windows\System32\Config\SYSTEM %usb_output_dir%
COPY %target_drive%[root]\Windows\System32\Config\SOFTWARE %usb_output_dir%
COPY %target_drive%[root]\Users\%target_user%\NTUSER.DAT %usb_output_dir%
COPY %target_drive%[root]\Windows\Inf\setupapi.dev.log %usb_output_dir%

::Finish off the run
CD %start_dir%
ECHO Successful Finish!

::Concatenate all output?

SET %launch_usb_forensics%=
SET /p launch_usb_forensics="Do you want to launch USB Device Forensics? (Y/N) "
if "%launch_usb_forensics%" == "Y" (
	ECHO Kicking off USBDeviceForensics >> %run_log_file%
	ECHO Kicking off USBDeviceForensics for you
	PAUSE
	"C:\Forensic Program Files\Woanware\USBDeviceForensics.exe"
) ELSE (
	ECHO Not kicking off USBDeviceForensics >> %run_log_file%
	ECHO Not launching USBDeviceForensics
)