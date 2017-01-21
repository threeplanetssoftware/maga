::
:: ============================================
::         Make Analysis Great Again
:: ============================================
::.
::    _____      _____    ________    _____   
::   /     \    /  _  \  /  _____/   /  _  \  
::  /  \ /  \  /  /_\  \/   \  ___  /  /_\  \ 
:: /    Y    \/    !    \    \_\  \/    !    \
:: \____!__  /\____!__  /\______  /\____!__  /
::         \/         \/        \/         \/ 
::.
:: ============================================
::         Make Analysis Great Again
:: ============================================
::
:: About:
::   MAGA is a quick script hacked together in SANS FOR408 
::   to automate some of the command line work for students
::   not used to CLI. It is not intended as a fully functional
::   forensic suite, merely a tool to help demonstrate the 
::   types of information available for forensic analysts
::   after using these command-line tools. MAGA uses the
::   common tools provided for FOR408, primarily those by
::   tzworks due to consistant output, good documentation, 
::   and ease of scripting.
::
:: Author: Jon Baumann, Three Planets Software
::   https://github.com/threeplanetssoftware/
::
@ECHO OFF

::Initialize variables
SET target_user=
SET target_drive=
SET launch_usb_forensics=
SET target_hostname=

::Programs, assuming a default SIFT workstation
SET parse_rs="C:\Forensic Program Files\RecoverRS\ParseRS.exe"
SET regripper_dir="C:\Forensic Program Files\Registry Tools\Registry Ripper"
SET usb_device_forensics="C:\Forensic Program Files\Woanware\USBDeviceForensics.exe"

::Root level
SET start_dir=%CD%
SET run_log_file=%start_dir%\run_log.txt REM Logging could use some work, this was just enough for my ensuring the script worked
SET error_log_file=%start_dir%\error_log.txt

::Input/output folders
SET input_dir=%start_dir%\input
SET output_dir=%start_dir%\output

:: Registry Folders
SET registry_input_dir=%input_dir%\registry
SET registry_output_dir=%output_dir%\registry

:: Cafae folders
SET cafae_output_dir=%output_dir%\cafae

:: Prefetch Folders
SET prefetch_input_dir=%input_dir%\prefetch
SET prefetch_output_dir=%output_dir%\prefetch

:: Jumplist Folders
SET auto_dest_input_dir=%input_dir%\automatic_destinations
SET cust_dest_input_dir=%input_dir%\custom_destinations
SET jumplist_output_dir=%output_dir%\jumplist

:: USB Folders
SET usb_output_dir=%output_dir%\usb

:: IE Recovery Data
SET recovery_input_dir=%input_dir%\recovery_store
SET recovery_output_dir=%output_dir%\recovery_store

:: SBAG Folders
SET sbag_output_dir=%output_dir%\sbag

:: Event Log Folders
SET evtx_output_dir=%output_dir%\event_logs

ECHO ===Starting new MAGA run at %DATE% %TIME%=== >> %run_log_file%
ECHO.
ECHO ============================================
ECHO         Make Analysis Great Again
ECHO ============================================
ECHO.
ECHO    _____      _____    ________    _____   
ECHO   /     \    /  _  \  /  _____/   /  _  \  
ECHO  /  \ /  \  /  /_\  \/   \  ___  /  /_\  \ 
ECHO /    Y    \/    !    \    \_\  \/    !    \
ECHO \____!__  /\____!__  /\______  /\____!__  /
ECHO         \/         \/        \/         \/ 
ECHO.
ECHO ============================================
ECHO         Make Analysis Great Again
ECHO ============================================
ECHO.

::
::
::
::

ECHO.
SET /p target_hostname="Type the hostname for the acquired media (i.e. ASGARD, or unknown): "
ECHO Setting the target hostname to be %target_hostname%

:: Find out where we're mounted
ECHO.
SET /p target_drive="Type the drive letter for the forensic image (i.e. E:\): "
IF NOT "%target_drive%" == "C:\" (
	:: Checking for a mounted image
	IF EXIST %target_drive%[root] (
		SET target_drive=%target_drive%[root]\
	)
) ELSE (
	ECHO.
	ECHO I see you're checking the C:\ drive... this likely won't end well due to locked files
	ECHO.
	PAUSE
)
ECHO Working from mounted image on: %target_drive% 
ECHO Hope this is correct...

:: Check to make sure we have the right drive
set users_dir=%target_drive%Users\
IF NOT EXIST "%users_dir%" (
	ECHO I don't believe the drive is correct because "%users_dir%" does not exist
	PAUSE
	EXIT /B
)

:: Find out target user
ECHO.
ECHO.
ECHO Users on this system are:
DIR /b /AD "%target_drive%Users\"
ECHO.
SET /p target_user="Which user is the target? (i.e. Donald): "
ECHO.
ECHO Targeting user located at: "%target_drive%Users\%target_user%"
ECHO BTW, I'm about to remove the output folder (%output_dir%) so if you ran this before, save your files off
ECHO.
PAUSE

:: Check to make sure we have the right user
set target_user_dir=%users_dir%%target_user%
IF NOT EXIST "%target_user_dir%" (
	ECHO I don't believe the drive is correct because "%target_user_dir%" does not exist
	PAUSE
	EXIT /B
)

::
::
:: Prep work for directories
::
::

:: Checking input dirs
ECHO Checking input directories
ECHO Checking input directory: %input_dir% >> %run_log_file%

:: Need to remove and create input dir
ECHO Making input directories
ECHO Removing input dir to rebuild >> %run_log_file%
IF EXIST %input_dir% (
	RMDIR /S /Q %input_dir%
)
MKDIR %input_dir%

:: Need to create input dirs
ECHO Creating input folders >> %run_log_file%
MKDIR %prefetch_input_dir%
MKDIR %registry_input_dir%
MKDIR %auto_dest_input_dir%
MKDIR %cust_dest_input_dir%
MKDIR %recovery_input_dir%

:: Need to remove and create output dir
ECHO Making output directories
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
MKDIR %usb_output_dir%
MKDIR %cafae_output_dir%
MKDIR %recovery_output_dir%
MKDIR %evtx_output_dir%

::
::
:: Event log forensics
::
::

::Event Log work
ECHO Working on event logs >> %run_log_file%
ECHO Attempting to pull event logs from %target_drive%
DIR %target_drive%Windows\System32\winevt\Logs\*.evtx /b /s | evtwalk -pipe -timeformat hh:mm:ss -csvl2t -no_whitespace > %evtx_output_dir%\event_logs.csv
ECHO --Done with event logs >> %run_log_file%

::
::
:: IE Recovery work
::
::

:: Grab IE Recovery information
SET target_user_ie_recovery_dir=%target_user_dir%\AppData\Local\Microsoft\Internet Explorer\Recovery\Active
CD "%recovery_input_dir%"
IF EXIST "%target_user_ie_recovery_dir%\*.dat" (
	ECHO Grabbing IE Recovery Files from "%target_user_ie_recovery_dir%" >> "%run_log_file%"
	ECHO Fetching IE recovery information REM from "%target_user_ie_recovery_dir%"
	COPY "%target_user_ie_recovery_dir%\R*.dat" .
	COPY "%target_user_ie_recovery_dir%\{*.dat" .
	%parse_rs% /d "%recovery_input_dir%" > "%recovery_output_dir%\recovery_data.txt"
	ECHO.
	ECHO ParseRS bombs out if the file on the image is locked, if an error appears above other than permissions, you may want to redo this manually by exporting
	ECHO.
	PAUSE
) ELSE (
	ECHO Not pulling IE Recovery information as I don't think it exists
)

::
::
:: Registry work (RegRipper, sbag, CAFAE)
::
::

::Copy Registry hives
ECHO Copying registry fies to input dir >> %run_log_file%
ECHO Grabbing registry files
CD "%registry_input_dir%"
DEL /Q *
COPY "%target_drive%Users\%target_user%\NTUSER.DAT" .
COPY "%target_drive%Users\%target_user%\AppData\Local\Microsoft\Windows\UsrClass.dat" .
COPY "%target_drive%Windows\System32\Config\DEFAULT" .
COPY "%target_drive%Windows\System32\Config\SAM" .
COPY "%target_drive%Windows\System32\Config\SECURITY" .
COPY "%target_drive%Windows\System32\Config\SOFTWARE" .
COPY "%target_drive%Windows\System32\Config\SYSTEM" .

::Do SBAG work while we're here
IF EXIST UsrClass.dat (
	ECHO "Ripping shellbags from %registry_input_dir%\UsrClass.dat" >> %run_log_file%
	sbag UsrClass.dat -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -hostname "%target_hostname%" -username "%target_user%" > %sbag_output_dir%\sbag.csv
) ELSE (
	ECHO "%registry_input_dir%\UsrClass.dat" not found for shellbags >> %run_log_file%
)

::Do CAFAE work while we're here
IF EXIST NTUSER.DAT (
	ECHO "Ripping CAFAE information from %registry_input_dir%\NTUSER.DAT" >> %run_log_file%
	:: Anyone actually reading this would be better served to use cafae's -all_user option to see even more
	cafae -hive NTUSER.DAT -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -userassist -hostname "%target_hostname%"  -username "%target_user%" > %cafae_output_dir%\userassist.csv
	cafae -hive NTUSER.DAT -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -openrun_mru -hostname "%target_hostname%"  -username "%target_user%" > %cafae_output_dir%\run_mru.csv
	cafae -hive NTUSER.DAT -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -opensave_mru -hostname "%target_hostname%"  -username "%target_user%" > %cafae_output_dir%\save_mru.csv
	cafae -hive NTUSER.DAT -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -recent_docs -hostname "%target_hostname%"  -username "%target_user%" > %cafae_output_dir%\recent_docs.csv
) ELSE (
	ECHO "%registry_input_dir%\NTUSER.DAT" not found for CAFAE >> %run_log_file%
)

::Do CAFAE work while we're here
IF EXIST SYSTEM (
	ECHO "Ripping CAFAE information from %registry_input_dir%\SYSTEM" >> %run_log_file%
	:: Anyone actually reading this would be better served to use cafae's -all_system option
	cafae -hive SYSTEM -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -devices -hostname "%target_hostname%"  > %cafae_output_dir%\devices.csv
	cafae -hive SYSTEM -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -timezone -hostname "%target_hostname%"  > %cafae_output_dir%\timezone.csv
	cafae -hive SYSTEM -quiet -base10 -csvl2t -timeformat hh:mm:ss -no_whitespace -shimcache -hostname "%target_hostname%"  > %cafae_output_dir%\shimcache.csv
) ELSE (
	ECHO "%registry_input_dir%\SYSTEM not found for CAFAE" >> %run_log_file%
)

::Do RegRipper Work
ECHO.
ECHO About to run RegRipper, if this hangs you did not get the latest version. 
ECHO Download it from the dropbox and replace everything here: %regripper_dir%
ECHO.
PAUSE
ECHO Entering RegRipper Directory: %regripper_dir%
CD %regripper_dir%
IF EXIST %registry_input_dir%\NTUSER.DAT (
	ECHO "Ripping NTUSER.DAT from %registry_input_dir%\NTUSER.DAT" >> %run_log_file%
	rip.exe -r %registry_input_dir%\NTUSER.DAT -f ntuser > %registry_output_dir%\ntuser.txt
) ELSE (
	ECHO %registry_input_dir%\NTUSER.DAT not found >> %run_log_file%
)

IF EXIST %registry_input_dir%\SYSTEM (
	ECHO "Ripping SYSTEM from %registry_input_dir%\SYSTEM" >> %run_log_file%
	rip.exe -r %registry_input_dir%\SYSTEM -f system > %registry_output_dir%\system.txt
) ELSE (
	ECHO %registry_input_dir%\SYSTEM not found >> %run_log_file%
)

IF EXIST %registry_input_dir%\SOFTWARE (
	ECHO "Ripping SOFTWARE from %registry_input_dir%\SOFTWARE" >> %run_log_file%
	rip.exe -r %registry_input_dir%\SOFTWARE -f software > %registry_output_dir%\software.txt
) ELSE (
	ECHO %registry_input_dir%\SOFTWARE not found >> %run_log_file%
)

IF EXIST %registry_input_dir%\SECURITY (
	ECHO "Ripping SECURITY from %registry_input_dir%\SECURITY" >> %run_log_file%
	rip.exe -r %registry_input_dir%\SECURITY -f security > %registry_output_dir%\security.txt
) ELSE (
	ECHO %registry_input_dir%\SECURITY not found >> %run_log_file%
)

IF EXIST %registry_input_dir%\SAM (
	ECHO "Ripping SAM from %registry_input_dir%\SAM" >> %run_log_file%
	rip.exe -r %registry_input_dir%\SAM -f sam > %registry_output_dir%\sam.txt
) ELSE (
	ECHO %registry_input_dir%\SAM not found >> %run_log_file%
)

IF EXIST %registry_input_dir%\UsrClass.dat (
	ECHO "Ripping UsrClass.dat from %registry_input_dir%\UsrClass.dat" >> %run_log_file%
	rip.exe -r %registry_input_dir%\UsrClass.dat -f usrclass > %registry_output_dir%\usrclass.txt
) ELSE (
	ECHO %registry_input_dir%\UsrClass.dat not found >> %run_log_file%
)
ECHO --Done with registries >> %run_log_file%

::
::
:: Prefetch work
::
::

::Prefetch Work
ECHO Working on prefetch >> %run_log_file%
ECHO Entering Prefetch Dir: %prefetch_input_dir%
CD "%prefetch_input_dir%"
COPY "%target_drive%Windows\Prefetch\*.pf" .
ECHO "Ripping Prefetch from %prefetch_input_dir%" >> %run_log_file%
DIR *.pf /b | pf -pipe -csvl2t -timeformat hh:mm:ss -no_whitespace -hostname "%target_hostname%" > %prefetch_output_dir%\prefetch-all.csv
ECHO --Done with prefetch >> %run_log_file%

::
::
:: Jumplist work
::
::

:: Automatic jumplists
SET target_user_auto_dest_dir=%target_drive%Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations
ECHO Working on automatic jumplists >> %run_log_file%
IF EXIST "%target_user_auto_dest_dir%" (
	ECHO Entering Automatic Destination Dir: %auto_dest_input_dir%
	CD "%auto_dest_input_dir%"
	COPY "%target_user_auto_dest_dir%\*ions-ms" .
	DIR *ions-ms /b | jmp -pipe -quiet -csvl2t -base10 -timeformat hh:mm:ss -no_whitespace -hostname "%target_hostname%" -username "%target_user%" > %jumplist_output_dir%\jump-auto.csv
) ELSE (
	ECHO Skipping automatic destinations as I don't believe they exist
)
ECHO --Done with automatic jumplists >> %run_log_file%

:: Custom jumplists
SET target_user_cust_dest_dir=%target_drive%Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations
ECHO Working on custom jumplists >> %run_log_file%
IF EXIST "%target_user_cust_dest_dir%" (
	ECHO Entering Custom Destination Dir: %cust_dest_input_dir%
	CD "%cust_dest_input_dir%"
	COPY "%target_user_cust_dest_dir%\*ions-ms" .
	DIR *ions-ms /b | jmp -pipe -quiet -csvl2t -base10 -timeformat hh:mm:ss -no_whitespace -hostname "%target_hostname%" -username "%target_user%" > %jumplist_output_dir%\jump-custom.csv
) ELSE (
	ECHO Skipping custom destinations as I don't believe they exist
)
ECHO --Done with custom jumplists >> %run_log_file%

::
::
:: USB work
::
::

::Copy USB files
ECHO Copying files needed for USBDevice Forensics to %usb_output_dir%. Please run that tool!
ECHO Copying USB fies to output dir >> %run_log_file%
CD %usb_output_dir%
COPY "%target_drive%Windows\System32\Config\SYSTEM" %usb_output_dir%
COPY "%target_drive%Windows\System32\Config\SOFTWARE" %usb_output_dir%
COPY "%target_drive%Users\%target_user%\NTUSER.DAT" %usb_output_dir%
COPY "%target_drive%Windows\Inf\setupapi.dev.log" %usb_output_dir%

::
::
::
::

::Finish off the run
CD %start_dir%
ECHO.
ECHO Successful Finish!
ECHO.
::Concatenate all output?

::
::
::
::

SET /p launch_usb_forensics="Do you want to launch USB Device Forensics? (Y/N) "
if "%launch_usb_forensics%" == "Y" (
	ECHO Kicking off USBDeviceForensics >> %run_log_file%
	ECHO.
	ECHO Kicking off USBDeviceForensics for you. Point it at the %usb_output_dir% folder to find all your files
	ECHO.
	%usb_device_forensics%
) ELSE (
	ECHO Not kicking off USBDeviceForensics >> %run_log_file%
	ECHO Not launching USBDeviceForensics
)
PAUSE