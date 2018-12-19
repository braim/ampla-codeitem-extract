# ampla-codeitem-extract
Script to extract code items from an Ampla project

# How to run
assuming you have copied the project XML to same directory where the script is with name "AmplaExport.xml" and you are in that directory in Terminal window

`PowerShell .\CodeItemExtractionScript.ps1 AmplaExport.xml`

the script is going to create a folder and dump all files there

Note: you should have the permissions to run scripts downloaded. use this command in PowerShell

`Set-ExecutionPolicy -Scope CurrentUser Unrestricted`

Note: The result will not build. To build you would need references to Ampla DLLs