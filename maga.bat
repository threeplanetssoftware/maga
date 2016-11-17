:: Assumptions:
:: Outputs:
::	[root]\maga\output\
::	- Output folder with:
::		- Registry subfolder [DONE]
::		- Jumplist folder [DONE]
::		- Prefetch folder [DONE]
::		- USB folder [DONE]
::
@ECHO OFF

::Initialize variables
SET target_user=
SET target_drive=
SET launch_usb_forensics=

::Programs
SET parse_rs="C:\Forensic Program Files\RecoverRS\ParseRS.exe"
SET regripper_dir="C:\Forensic Program Files\Registry Tools\Registry Ripper"
SET usb_device_forensics="C:\Forensic Program Files\Woanware\USBDeviceForensics.exe"

::Root level
REM SET start_dir=C:\cases\maga
SET start_dir=%CD%
SET run_log_file=%start_dir%\run_log.txt
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

:: Checking input dirs
ECHO Checking input directories
ECHO Checking input directory: %input_dir% >> %run_log_file%

:: Need to remove input dir
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

:: Need to remove output dir
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


::
::
::
::

:: Find out where we're mounted
ECHO.
SET /p target_drive="Type the drive letter for the forensic image? (i.e. E:\): "
ECHO Working from mounted image on: %target_drive% 
ECHO Hope this is correct...

:: Check to make sure we have the right drive
set users_dir=%target_drive%[root]\Users\
IF NOT EXIST %users_dir% (
	ECHO I don't believe the drive is correct because %users_dir% does not exist
	EXIT /B
)

:: Find out target user
ECHO.
ECHO.
ECHO Users on this system are:
DIR /b /AD %target_drive%[root]\Users\
ECHO.
SET /p target_user="Which user is the target? (i.e. Donald): "
ECHO Targeting user located at: %target_drive%[root]\Users\%target_user% 
ECHO Hope this is correct...
PAUSE

:: Check to make sure we have the right user
set target_user_dir=%users_dir%%target_user%
IF NOT EXIST %target_user_dir% (
	ECHO I don't believe the drive is correct because %target_user_dir% does not exist
	EXIT /B
)

::
::
::
::

:: Grab IE Recovery information
SET target_user_ie_recovery_dir=%target_user_dir%\AppData\Local\Microsoft\Internet Explorer\Recovery\Active
CD %recovery_input_dir%
ECHO Grabbing IE Recovery Files from %target_user_ie_recovery_dir% >> %run_log_file%
ECHO Fetching IE recovery information
COPY "%target_user_ie_recovery_dir%\R*.dat" .
COPY "%target_user_ie_recovery_dir%\{*.dat" .
%parse_rs% /d %recovery_input_dir% > %recovery_output_dir%\recovery_data.txt
ECHO.
ECHO ParseRS bombs out occasionally, if an error appears above (other than permissions), you may want to redo this manually
ECHO.
PAUSE

::
::
::
::

::Copy Registry hives
ECHO Copying registry fies to input dir >> %run_log_file%
ECHO Grabbing registry files
CD %registry_input_dir%
DEL /Q *
COPY %target_drive%[root]\Users\%target_user%\NTUSER.DAT .
COPY %target_drive%[root]\Users\%target_user%\AppData\Local\Microsoft\Windows\UsrClass.dat .
COPY %target_drive%[root]\Windows\System32\Config\DEFAULT .
COPY %target_drive%[root]\Windows\System32\Config\SAM .
COPY %target_drive%[root]\Windows\System32\Config\SECURITY .
COPY %target_drive%[root]\Windows\System32\Config\SOFTWARE .
COPY %target_drive%[root]\Windows\System32\Config\SYSTEM .


::
::
::
::

::Do SBAG work while we're here
IF EXIST UsrClass.dat (
	ECHO "Ripping shellbags from %registry_input_dir%\UsrClass.dat" >> %run_log_file%
	sbag UsrClass.dat -base10 -csv -timeformat hh:mm:ss -no_whitespace > %sbag_output_dir%\sbag.csv
) ELSE (
	ECHO %registry_input_dir%\UsrClass.dat not found for shellbags >> %run_log_file%
)

::Do CAFAE work while we're here
IF EXIST NTUSER.DAT (
	ECHO "Ripping CAFAE information from %registry_input_dir%\NTUSER.DAT" >> %run_log_file%
	cafae -hive NTUSER.DAT -base10 -csv -timeformat hh:mm:ss -no_whitespace -userassist > %cafae_output_dir%\userassist.csv
	cafae -hive NTUSER.DAT -base10 -csv -timeformat hh:mm:ss -no_whitespace -openrun_mru > %cafae_output_dir%\run_mru.csv
	cafae -hive NTUSER.DAT -base10 -csv -timeformat hh:mm:ss -no_whitespace -opensave_mru > %cafae_output_dir%\save_mru.csv
	cafae -hive NTUSER.DAT -base10 -csv -timeformat hh:mm:ss -no_whitespace -recent_docs > %cafae_output_dir%\recent_docs.csv
) ELSE (
	ECHO %registry_input_dir%\NTUSER.DAT not found for CAFAE >> %run_log_file%
)

::Do CAFAE work while we're here
IF EXIST SYSTEM (
	ECHO "Ripping CAFAE information from %registry_input_dir%\SYSTEM" >> %run_log_file%
	cafae -hive SYSTEM -base10 -csv -timeformat hh:mm:ss -no_whitespace -devices > %cafae_output_dir%\devices.csv
	cafae -hive SYSTEM -base10 -csv -timeformat hh:mm:ss -no_whitespace -timezone > %cafae_output_dir%\timezone.csv
	cafae -hive SYSTEM -base10 -csv -timeformat hh:mm:ss -no_whitespace -shimcache > %cafae_output_dir%\shimcache.csv
) ELSE (
	ECHO %registry_input_dir%\SYSTEM not found for CAFAE >> %run_log_file%
)

::
::
::
::

REM ::Do RegRipper Work
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

::
::
::
::

::Prefetch Work
ECHO Working on prefetch >> %run_log_file%
ECHO Entering Prefetch Dir: %prefetch_input_dir%
CD %prefetch_input_dir%
::Clear out directory
DEL /Q *.pf
::Assuming E:\[root]\Windows\Prefetch\*.pf for prefetch
COPY %target_drive%[root]\Windows\Prefetch\*.pf .
DIR
ECHO "Ripping Prefetch from %prefetch_input_dir%" >> %run_log_file%
DIR *.pf /b | pf -pipe -csvl2t -timeformat hh:mm:ss -no_whitespace > %prefetch_output_dir%\prefetch-all.csv
ECHO --Done with prefetch >> %run_log_file%

::
::
::
::

:: Jumplist Work
ECHO Working on automatic jumplists >> %run_log_file%
ECHO Entering Automatic Destination Dir: %auto_dest_input_dir%
CD %auto_dest_input_dir%
::Clear out directory
DEL /Q *ions-ms
::Assuming E:\[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations for prefetch
COPY %target_drive%[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\*ions-ms .
DIR *ions-ms /b | jmp -pipe -csv -base10 -timeformat hh:mm:ss -no_whitespace > %jumplist_output_dir%\jump-auto.csv
ECHO --Done with automatic jumplists >> %run_log_file%

:: Jumplist Work
ECHO Working on custom jumplists >> %run_log_file%
ECHO Entering Custom Destination Dir: %cust_dest_input_dir%
CD %cust_dest_input_dir%
::Clear out directory
DEL /Q *ions-ms
::Assuming E:\[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations for prefetch
COPY %target_drive%[root]\Users\%target_user%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\*ions-ms .
DIR *ions-ms /b | jmp -pipe -csv -base10 -timeformat hh:mm:ss -no_whitespace > %jumplist_output_dir%\jump-custom.csv
ECHO --Done with custom jumplists >> %run_log_file%

::
::
::
::

::Copy USB files
ECHO Copying files needed for USBDevice Forensics to %usb_output_dir%. Please run that tool!
ECHO Copying USB fies to output dir >> %run_log_file%
CD %usb_output_dir%
COPY %target_drive%[root]\Windows\System32\Config\SYSTEM %usb_output_dir%
COPY %target_drive%[root]\Windows\System32\Config\SOFTWARE %usb_output_dir%
COPY %target_drive%[root]\Users\%target_user%\NTUSER.DAT %usb_output_dir%
COPY %target_drive%[root]\Windows\Inf\setupapi.dev.log %usb_output_dir%

::
::
::
::

::Finish off the run
CD %start_dir%
ECHO Successful Finish!

::Concatenate all output?

::
::
::
::

SET /p launch_usb_forensics="Do you want to launch USB Device Forensics? (Y/N) "
if "%launch_usb_forensics%" == "Y" (
	ECHO Kicking off USBDeviceForensics >> %run_log_file%
	ECHO Kicking off USBDeviceForensics for you
	PAUSE
	%usb_device_forensics%
) ELSE (
	ECHO Not kicking off USBDeviceForensics >> %run_log_file%
	ECHO Not launching USBDeviceForensics
)
PAUSE