/* -- This is the myPython Installer -- */
/* It will create the virtual environment executable and download necessary wheels*/

; include for some of the windows messages defines
!include "winmessages.nsh"
RequestExecutionLevel user

# Constants
Name "myPython Installer"
OutFile "..\myPython.exe"
InstallDir "C:\virtualenvs\TEMP"

# Installer Pages
Page instfiles

Section "Install"
		# myPython Version
		Var /GLOBAL PACK
        SetOutPath "$TEMP\"
		File "..\packages\*.*"
		FileOpen $0 "myPython.version" r
        FileRead $0 $1
        checkvers:
          StrCmp $1 "" checked
          DetailPrint "Preparing to Install myPython Version - $1"
          StrCpy $PACK $1 -1
		  FileRead $0 $1
          Goto checkvers
        checked:
          FileClose $0
		
		# Python Version
		Var /GLOBAL ROOTPY
		FileOpen $0 "python.version" r
        FileRead $0 $1
        pythonvers:
          StrCmp $1 "" correct
          DetailPrint "Checking for Root Python Version - $1"
          StrCpy $ROOTPY $1 -1
		  FileRead $0 $1
          Goto pythonvers
        correct:
          FileClose $0

		# check if Python Installation exists
		IfFileExists "$LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe" +5 0
        DetailPrint "$LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe not found!"
        DetailPrint "Please install $ROOTPY for $PACK first! Aborting ..."
        MessageBox MB_OK "Error: Python Installation for $PACK not found!"
        Goto veryend

        GetDlgItem $0 $HWNDPARENT 2
        EnableWindow $0 1
		
		
        # clean previous installation
        DetailPrint "Clean previous virtualenv with same name"
		StrCpy $INSTDIR "C:\virtualenvs\$PACK"
        RMDir /r $INSTDIR
		
        # Create virtenv
        DetailPrint "Install VirtualEnv & Windows Wrapper"
        FileOpen $0 "venv.list" r
        FileRead $0 $1
        loop:
          StrCmp $1 "" done
          DetailPrint "$1"
          nsExec::ExecToLog "$SYSDIR\cmd.exe /C $LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe -m pip install --no-deps $EXEDIR\$1"
		  FileRead $0 $1
          Goto loop
        done:
          FileClose $0
		DetailPrint "Create VirtualEnv $PACK"
        ReadEnvStr $R0 COMSPEC
		nsExec::ExecToLog "$SYSDIR\cmd.exe /C SET PATH=%LOCALAPPDATA%\Programs\Python\$ROOTPY\;%LOCALAPPDATA%\Programs\Python\$ROOTPY\Scripts;%PATH% && mkvirtualenv $PACK $INSTDIR"
		
        # Install pip packages from wheels
        DetailPrint "Install Packages"
        FileOpen $0 "wheel.list" r
        FileRead $0 $1
        pipinstall:
          StrCmp $1 "" final
          DetailPrint "$INSTDIR\Scripts\python.exe -m pip install --no-deps $EXEDIR\$1"
          nsExec::ExecToLog "$SYSDIR\cmd.exe /C $INSTDIR\Scripts\python.exe -m pip install --no-deps $EXEDIR\$1"
		  FileRead $0 $1
          Goto pipinstall
        final:
          FileClose $0
		
        # Create requirements.txt
        nsExec::ExecToLog "$SYSDIR\cmd.exe /C $INSTDIR\Scripts\python.exe -m pip freeze -l > $INSTDIR\requirements.txt"
        DetailPrint "Freeze and Copy requirements.txt file."
        SetOutPath "$INSTDIR\"
        veryend:
SectionEnd
