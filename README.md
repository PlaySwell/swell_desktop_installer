## Shopswell Desktop App Installer
### How to build the installer using the Inno ISCC command line setup compiler
##### Install the prerequisites
1. [Install Inno version 5](http://www.jrsoftware.org/download.php/is.exe?site=1)
2. [Install node.js](https://nodejs.org/dist/v4.2.1/win-x64/node.exe)
3. Install nw.js (`npm install nw` after node.js is installed)
4. Install required nw packages (`npm install` for: `node-notifier, node-schedule, path, request, wake-event`)
5. Check out Github project: (https://github.com/PlaySwell/swell_desktop)
##### Generic script usage
`iscc NwjsSource ModuleSource SwellSource`
* `NwjsSource` is the path to the directory (`.\nwjs`) which contains the nw.exe from node-webkit (nw)
* `ModuleSource` is the path to the directory (`.\node_modules`) which contains installed packages from 4. above
* `SwellSource` is the path to the directory which contains the checked out `.\swell_desktop` repository
##### Passing parameters with /d defined parameters
```
<path to iscc.exe>\iscc "/dNwjsSource=<path to nw.exe>" "/dModuleSource=<path to .\node_modules>" "/dSwellSource=<path to local swell_desktop repo>" setup.iss
``` 
##### Example script usage with specific paths
```
"C:\Program Files (x86)\Inno Setup 5\iscc" "/dNwjsSource=c:\nwjs" "/dModuleSource=c:\nwjs\node_modules" "/dSwellSource=c:\swell_desktop" setup.iss
```
##### Running the installer
In normal verbose mode:   `shopswell-setup-1.0.0.exe`
In very silent mode:      `shopswell-setup-1.0.0.exe /SP /VERYSILENT`
      
