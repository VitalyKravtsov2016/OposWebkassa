[Setup]
AppName="SHTRIH-M: WebKassa OPOS driver"
AppVerName="SHTRIH-M: WebKassa OPOS driver ${version2}"
AppPublisher=SHTRIH-M
AppCopyright="Copyright, 2022 SHTRIH-M"
VersionInfoCompany="SHTRIH-M"
VersionInfoDescription="WebKassa OPOS fiscal printer driver"
AppVersion=${version2}
AppPublisherURL=http://www.shtrih-m.ru
AppSupportURL=http://www.shtrih-m.ru
AppUpdatesURL=http://www.shtrih-m.ru
AppContact=�.(495) 787-6090
AppReadmeFile=History.txt
;������
VersionInfoTextVersion="${version}"
VersionInfoVersion=${version}
DefaultDirName= {pf}\OPOS\WebKassa\
DefaultGroupName=OPOS\WebKassa\
UninstallDisplayIcon= {app}\Uninstall.exe
AllowNoIcons=Yes
OutputDir="."
[Setup]
OutputBaseFilename=Setup
[Components]
Name: "main"; Description: "Driver files"; Types: full compact custom; Flags: fixed
[Dirs]
Name: "{app}\Logs"; components: main;
[Files]
; OpenSSL
Source: "Setup\libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: main
Source: "Setup\ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: main
; Barcode render
Source: "Setup\zint.dll"; DestDir: "{app}"; Flags: ignoreversion; components: main;
Source: "Setup\Translation\OposWebkassa.RUS"; DestDir: "{app}\Translation"; Flags: ignoreversion; components: main;
Source: "Setup\Translation\OposWebkassa.KAZ"; DestDir: "{app}\Translation"; Flags: ignoreversion; components: main;
; Fonts
Source: "Setup\Fonts\KazakhFontA.bmp"; DestDir: "{app}\Fonts"; Flags: ignoreversion; components: main;
Source: "Setup\Fonts\KazakhFontB.bmp"; DestDir: "{app}\Fonts"; Flags: ignoreversion; components: main;
; Version history
Source: "History.txt"; DestDir: "{app}"; Flags: ignoreversion; components: main;
; Drivers
Source: "Bin\OposWebkassa.dll"; DestDir: "{app}"; Flags: ignoreversion regserver; components: main;
; Configuration utility
Source: "Bin\OposConfig.exe"; DestDir: "{app}"; Flags: ignoreversion; components: main;
; Test utility
Source: "Bin\OposTest.exe"; DestDir: "{app}"; Flags: ignoreversion; components: main;
[Icons]
Name: "{group}\Version history"; Filename: "{app}\History.txt"; WorkingDir: "{app}";
Name: "{group}\Opos setup"; Filename: "{app}\OposConfig.exe"; WorkingDir: "{app}";
Name: "{group}\Opos test"; Filename: "{app}\OposTest.exe"; WorkingDir: "{app}";
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"
[Registry]
; FiscalPrinter default device
Root: HKLM; Subkey: "SOFTWARE\OLEforRetail\ServiceOPOS\FiscalPrinter\SHTRIH-M-OPOS-1"; ValueType: string; ValueName: ""; ValueData: "OposWebkassa.FiscalPrinter"; 
[UninstallDelete]
Type: files; Name: "{app}\Logs\*.log"












