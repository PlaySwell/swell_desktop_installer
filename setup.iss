; Comment: "Shopswell Desktop App Setup Script for Inno" 
; John H - Oct 26 2015
;
; TODO - Parameterize this script
;

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
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
Compression=zip
SolidCompression=yes
OutputDir=.
OutputBaseFilename=shopswell-setup-{#MyAppVersion}
ShowLanguageDialog=auto
PrivilegesRequired=admin

[Files]
; TODO - rework this to pull explicit source files from different directories
Source: "c:/nwjs/*"; Excludes: "mac_files,pdf.dll,ffmpegsumo.dll,libEGL.dll,libGLESv2.dll,.gitignore,README.md"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Registry]
; Add the 'run on startup' registry key
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\nw.exe"""; Flags: uninsdeletevalue; 

; Add HKEY_LOCAL_MACHINE unique-to-shopswell key - delete on uninstall if empty
Root: HKLM; Subkey: "Software\{#MyAppPublisher}"; Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}\Settings"; ValueType: string; ValueName: "UniqueShopswellKey"; ValueData: "{#MyAppId}"; Flags: uninsdeletevalue;

[Tasks]
Name: "desktopicon"; Description: "{#CreateDesktopIcon}"; GroupDescription: "{#DesktopIcon}"

[Icons]
; Add program group, startup menu choices and desktop icon
Name: "{group}\{#MyAppPublisher}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"; Tasks: desktopicon

[Run]
; After installing, run the app
Filename: "{app}\nw.exe"; WorkingDir: "{app}"; Description: {#LaunchProgram}; Flags: postinstall shellexec
