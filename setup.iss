Comment: "Shopswell Desktop App Setup Script for Inno"

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
Source: "c:/nwjs/*"; Excludes: "mac_files,pdf.dll,ffmpegsumo.dll,libEGL.dll,libGLESv2.dll,.gitignore,README.md"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Registry]
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\nw.exe"""; Flags: uninsdeletevalue; 

[Tasks]
Name: "desktopicon"; Description: "{#CreateDesktopIcon}"; GroupDescription: "{#DesktopIcon}"

[Icons]
Name: "{group}\Shopswell"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userstartup}\Shopswell App"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"
Name: "{userdesktop}\Shopswell App"; Filename: "{app}\nw.exe"; WorkingDir: "{app}"; IconFilename: "{app}\icons\logo.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\nw.exe"; WorkingDir: "{app}"; Description: {#LaunchProgram}; Flags: postinstall shellexec
