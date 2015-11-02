; Shopswell Desktop App Setup Script for Inno                                                                                              
; John H - Oct 26 2015
;
; TODO: 
; 0. DONE - Verify the naming of things (from the .exe to the App name, to the the folder names etc.) with the Playswell folks
; 1. Work on a more silent install ... can we get rid of the initial "Do you want this program to mke changes" prompt?
;    (/SP flag is supposed to do this but appear not to)
; 2. Testing non-admin user accounts
; 3. Testing with Windows 10
; 4. Testing scenarios where restart might be required
; 5. Uninstall when the app is running needs to stop the running app first
; 6. DONE Try to "exclude" .gitignore & README.md from install 
; 7. Delve into the 32 v2 64 bit issues related to where HKLM keys are being stored is "Wow6432Node" OK?
; 8. Test on 32 bit OS (related to #7 - the issue is the Hardcandy requirement to have an identifiable key which can be tested after install/uninstall:
; "Please provide a registry key (or other critical, unique file) that will exist after your product is installed and will not exist after your product is uninstalled"
; This is currently set as: HKLM\Software\Shopswell\Shopswell App\Settings UniqueShopswellKey = ShopswellAppId
; But on 64 bit machines, this is actually set into:
; HKLM\Software\Wow6432Node\Shopswell\Shopswell App\Settings UniqueShopswellKey = ShopswellAppId 
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
; - NwjsSource is the path to the directory (.\nwjs) which contains the nw.exe from node-webkit (aka nw)
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
; In silent mode:           shopswell.exe /SP /VERYSILENT /NORESTART /SUPPRESSMSGBOXES    



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
#define MyAppId "ShopswellAppId"
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
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppPublisher} 
UninstallDisplayIcon="{app}\icons\logo.ico"
SetupIconFile="{#SwellSource}\icons\logo.ico"

[Files]
Source: "{#NwjsSource}/*"; Excludes: "pdf.dll,ffmpegsumo.dll,libEGL.dll,libGLESv2.dll"; DestDir: "{app}"; Flags: ignoreversion 
Source: "{#ModuleSource}/*"; DestDir: "{app}\node_modules"; Flags: ignoreversion recursesubdirs 
Source: "{#SwellSource}/*"; Excludes: "app.nw,mac_files,README.md,.gitignore"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Registry]
; Add the 'run on startup' registry key
; Add HKEY_LOCAL_MACHINE unique-to-shopswell key - delete on uninstall if empty
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\nw.exe"""; Flags: uninsdeletevalue; 
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}\Settings"; Flags: uninsdeletekeyifempty
Root: "HKLM"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}\Settings"; ValueType: string; ValueName: "UniqueShopswellKey"; ValueData: "{#MyAppId}"; Flags: uninsdeletevalue;

[Tasks]
Name: "desktopicon"; Description: "{#CreateDesktopIcon}"; GroupDescription: "{#DesktopIcon}"

[Icons]
; Add program group, startup menu choices and desktop icon
Name: "{group}\{#MyAppName}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"; Tasks: desktopicon

[Run]
; After installing, run the app
Filename: "{app}\nw.exe"; WorkingDir: "{app}"; Description: {#LaunchProgram}; Flags: postinstall shellexec

[UninstallDelete]
Type: dirifempty; Name: "{app}\{#MyAppName}"
