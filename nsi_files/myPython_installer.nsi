/* -- This is the myPython Installer -- */
/* It will create the virtual environment executable and download necessary wheels*/

; include for some of the windows messages defines
!include "winmessages.nsh"
RequestExecutionLevel user

# Constants
Name "myPython Installer"
OutFile "..\myPython.exe"
InstallDir "C:\venvs\TEMP"

# Installer Pages
Page instfiles

Section "Install"
		# OptoPython Version
		Var /GLOBAL MYPY
        SetOutPath "$TEMP\"
		File "..\packages\*.*"
		FileOpen $0 "myPython.version" r
        FileRead $0 $1
        myvers:
          StrCmp $1 "" checked
          DetailPrint "Preparing to Install myPython Version - $1"
          StrCpy $MYPY $1 -1
		  FileRead $0 $1
          Goto myvers
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
		IfFileExists "$LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe" pyfound pynotfound
		pyfound:
			MessageBox MB_YESNO "$ROOTPY Installation found! Do you want a clean $ROOTPY install?" IDYES instpy IDNO noinstpy
		pynotfound:	
			DetailPrint "$LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe not found!"
			DetailPrint "Please install $ROOTPY for $MYPY first! Aborting ..."
			MessageBox MB_OKCANCEL "Error: Python Installation for $MYPY not found! Do you want to install $ROOTPY" IDOK instpy IDCANCEL veryend 
		instpy:
			DetailPrint "Installing $ROOTPY..."
			ExpandEnvStrings $R0 %COMSPEC%
			nsExec::Exec '"$R0" /C "$EXEDIR\resources\install_root_python.cmd" $EXEDIR\resources'
		noinstpy:
        GetDlgItem $0 $HWNDPARENT 2
        EnableWindow $0 1
		
		
        # clean previous installation
     	StrCpy $INSTDIR "C:\venvs\$MYPY"
		DetailPrint "Clean previous virtualenv with same name"
		IfFileExists "$INSTDIR\*.*" 0 +7
		MessageBox MB_OKCANCEL "$MYPY Installation found! Do you want to remove it?" IDOK true IDCANCEL cancel
		cancel:
			DetailPrint "Exiting..."
			Goto veryend
		true:
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
		DetailPrint "Create VirtualEnv $MYPY"
        
		nsExec::ExecToLog "$SYSDIR\cmd.exe /C $LOCALAPPDATA\Programs\Python\$ROOTPY\python.exe -m virtualenv $INSTDIR"
		nsExec::ExecToLog "$SYSDIR\cmd.exe /C $INSTDIR\Scripts\python.exe -m ensurepip"
		
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
        # End
        veryend:
SectionEnd
