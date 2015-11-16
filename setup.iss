; Shopswell Desktop App Setup Script for Inno                                                                                              
; John H - Oct 26 2015
;
; TODO: 
; 0. DONE - Verify the naming of things (from the .exe to the App name, to the the folder names etc.) with the Playswell folks
;
; 1. Work on a more silent install ... can we get rid of the initial "Do you want this program to make changes" prompt?
;    (/SP flag is supposed to do this but appear not to)
;    FIXED below by lowering privelege level to 'lowest'
;    TODO: Awaiting input from Shopswell re per-user install in Appdata vs. Program Files, HKCU vs. HKLU
;    RESOLVED: HC installer will wrap this install, it takes on the "do you want this programm..." prompts
;
; 2. DONE - Testing non-admin user accounts
;    Note: Non admin accounts will request a password when an install is attempted unless admin priveleges / per user install as per #1 above  
;    There are some ways around this but wil result in a per-user install
;    TODO: get guidance from Shopswell folks (same as #1)
;    RESOLVED: HC installer runs in admin mode, wrap this install
;
; 3. DONE - Testing with Windows 10 - install works fine
;    TODO - Uninstall may leave residue in registry - to be tracked down
;    
; 4. Testing scenarios where restart might be required
;    DONE - so far, in testing various accounts (admin, user, guest) this has not happened 
;
; 5. Uninstall when the app is running needs to stop the running app first
;    DONE - use 'killtask' on uninstall to kill the running instance of swell.exe
;
; 6. DONE - Try to "exclude" .gitignore & README.md from install 
;
; 7. Delve into the 32 v2 64 bit issues related to where HKLM keys are being stored is "Wow6432Node" OK?
; 8. Test on 32 bit OS (related to #7) - the issue is the Hardcandy requirement to have an identifiable key which can be tested after install/uninstall:
;   "Please provide a registry key (or other critical, unique file) that will exist after your product is installed and will not exist after your product is uninstalled"
;   This is currently set as: HKLM\Software\Shopswell\Shopswell App\Settings UniqueShopswellKey = ShopswellAppId
;   But on 64 bit machines, this is actually set into:
;   HKLM\Software\Wow6432Node\Shopswell\Shopswell App\Settings UniqueShopswellKey = ShopswellAppId 
;   PARTIALLY RESOLVED: Use the "HKLM\Software\Wow6432Node\..." key for detecting the successful install / uninstall
;   TODO: Test on a 32 bit OS
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Building an installer
;----------------------
; Prerequisites
; 1. Installed Inno version 5 (from http://www.jrsoftware.org/download.php/is.exe?site=1)
; 2. Installed node.js (from https://nodejs.org/dist/v4.2.1/win-x64/node.exe)
; 3. Installed nw.js (via 'npm install nw' after node.js was installed)
; 4. Installed packages in .\node_modules (via 'npm install' for: node-notifier, node-schedule, path, request, wake-event)
; 5. Checked out Github project: https://github.com/PlaySwell/swell_desktop
; 
; Generic script use 
; From the command line: iscc NwjsSource ModuleSource SwellSource 
; ...
; Where 
; - NwjsSource is the path to the directory (.\nwjs) which contains the original nw.exe from node-webkit (aka nw)
; - ModuleSource is the path to the directory (.\node_modules) which contains installed packages from 4. above
; - SwellSource is the path to the directory which contains the checked out .\swell_desktop repository
; 
; Actual Script Use with /d parameters
; <path to iscc.exe>\iscc "/dNwjsSource=<path to nw.exe>" "/dModuleSource=<path to .\node_modules>" "/dSwellSource=<path to local swell_desktop repo>" setup.iss
; 
; Example useage with actual paths:
; "C:\Program Files (x86)\Inno Setup 5\iscc" "/dNwjsSource=c:\nwjs" "/dModuleSource=c:\nwjs\node_modules" "/dSwellSource=c:\swell_desktop" setup.iss
; 
; Note: Parameters passed via the "/dname=value" on command line are accessible via "{#name}" in the script body
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------
; Running the installer
;----------------------
; In normal verbose mode:   shopswell.exe
; In silent mode:           shopswell.exe /SP- /SILENT /VERYSILENT /NORESTART /SUPPRESSMSGBOXES    
;
; NOTE: This installer will create the key: 
; [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Shopswell\Shopswell App\Settings] Name:UniqueShopswellKey Value:911176E3-243D-49D5-9CF0-34B1FB01CBE3
; on 64bit OSes
; The uninstall, if successful, removes this key
;
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------

; Default parameters, if not supplied on the command line
#ifndef NwjsSource
#define NwjsSource "c:\nwjs"
#endif

#ifndef ModuleSource
#define ModuleSource "c:\nwjs\node_modules"
#endif

#ifndef SwellSource
#define SwellSource "c:\swell_desktop"
#endif

; Other per-app constants
#define MyAppName "Shopswell App"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Shopswell"
#define MyAppURL "http://www.shopswell.com"
#define MyAppId "911176E3-243D-49D5-9CF0-34B1FB01CBE3"
#define MyExeName "swell.exe"
#define LaunchProgram "Start Shopswell App after Installation"
#define DesktopIcon "Add Desktop Shortcut"
#define CreateDesktopIcon "Do you want to create a desktop icon?"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
UninstallDisplayName={#MyAppName}
Compression=zip
SolidCompression=yes
OutputDir=.
OutputBaseFilename=shopswell
ShowLanguageDialog=auto
PrivilegesRequired=admin
DisableStartupPrompt=yes
UninstallRestartComputer=no
CloseApplications=yes
DefaultDirName={pf}\{#MyAppPublisher}
DefaultGroupName={#MyAppPublisher} 
UninstallDisplayIcon="{app}\{#MyAppName}\icons\logo.ico"
SetupIconFile="{#SwellSource}\icons\logo.ico"

[Files]
; Gather files from the node-webkit, node_modules and the swell_desktop checkout directories
; Install base node webkit, sans the not-needed files
Source: "{#NwjsSource}/*"; Excludes: "pdf.dll,ffmpegsumo.dll,libEGL.dll,libGLESv2.dll"; DestDir: "{app}\{#MyAppName}"; Flags: ignoreversion 
; Install the nw.exe but copy it to swell.exe so that we can kill our task when uninstalling without affecting other running nw.exe apps
Source: "{#NwjsSource}/nw.exe"; DestDir: "{app}\{#MyAppName}"; DestName: "{#MyExeName}"; Flags: ignoreversion 
; Install the supporting node modules
Source: "{#ModuleSource}/*"; DestDir: "{app}\{#MyAppName}\node_modules"; Flags: ignoreversion recursesubdirs  
; Install the actual Shopswell app files
Source: "{#SwellSource}/*"; Excludes: "app.nw,mac_files,README.md,.gitignore"; DestDir: "{app}\{#MyAppName}"; Flags: ignoreversion recursesubdirs 

[Registry]
; Add the 'run on startup' registry key
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\{#MyAppName}\{#MyExeName}"""; Flags: uninsdeletevalue; 
; Add unique-to-shopswell key tree - delete on uninstall 
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}\Settings"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}\Settings"; ValueType: string; ValueName: "UniqueShopswellKey"; ValueData: "{#MyAppId}"; Flags: uninsdeletevalue;

[Tasks]
; Ask user (in non-silent install) if they want to add icon to the desktop
Name: "desktopicon"; Description: "{#CreateDesktopIcon}"; GroupDescription: "{#DesktopIcon}"

[Icons]
; Add program group, startup menu choices and desktop icon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppName}\{#MyExeName}"; WorkingDir: "{app}\{#MyAppName}"; IconFilename: "{app}\{#MyAppName}\icons\logo.ico"
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppName}\{#MyExeName}"; WorkingDir: "{app}\{#MyAppName}"; IconFilename: "{app}\{#MyAppName}\icons\logo.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppName}\{#MyExeName}"; WorkingDir: "{app}\{#MyAppName}"; IconFilename: "{app}\{#MyAppName}\icons\logo.ico"; Tasks: desktopicon

[Run]
; After installing, run the app
Filename: "{app}\{#MyAppName}\{#MyExeName}"; WorkingDir: "{app}\{#MyAppName}"; Description: {#LaunchProgram}; Flags: postinstall shellexec

[UninstallRun]  
; Before uninstalling, kill the running app (otherwise uninstall will not be clean)  
Filename: "{cmd}"; Parameters: "/C ""taskkill /im {#MyExeName} /f /t"  
  
[UninstallDelete]
Type: filesandordirs; Name: "{app}\{#MyAppName}"