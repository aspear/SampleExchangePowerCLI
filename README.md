# SampleExchangePowerCLI Module

A PowerShell Module that contains integration between [VMware's new sample code repository Sample Exchange](developercenter.vmware.com/samples), and various
 PowerShell ISE.  Sample Exchange contains an ever growing catalog of PowerCLI samples and snippets, and this module uses Sample Exchange REST
 web services to allow a user to paste sample code into their editors directly in PowerShell ISE.

**Pre-Requisites**

PowerShell version 4 or later.

**Installation**

1) Download (or clone) all files comprising the module.

2) Create a folder for the module in your module folder path, e.g. C:\Users\username\Documents\WindowsPowerShell\Modules\SampleExchangePowerCLI

3) Place the module files in the above folder.  The SampleExchangePowerCLI.psd1 file should be in the root of the folder with the "functions" subdirectory below that contains all of the various functions.

NOTE: If you create the folder in the path above, then PowerShell ISE (and regular PowerShell windows) will load the module.  
 If you don't want to do this, you can manually install the module by running the command

 PS C:\> Import-Module -Force -Verbose C:\work\PowerShell\sample-exchange-powercli\SampleExchangePowerCLI
 
 where sample-exchange-powercli was the directory where the files where extracted.
 
 4) Restart PowerShell ISE
 
 5) Go to "Add-ons" > "Sample Exchange" > "Sync Snippets"
 
 This command is the equivilent of calling the "Sync-SampleExchangeSnippetsWithISE" method directly.  It downloads all samples and registers them as "Snippets" 
 in PowerShell ISE thus making them available for use in the editor when you issue the "CTRL + J" hot-key.
 
**Usage**

If you follow the steps above and restart PowerShell ISE you should see a "Sample Exchange" menu show up with a "Sync Snippets" and "Search Samples" commands.  
"Sync Snippets" is mentioned above in the installation steps.

*** Search Samples ***
"Search Samples" will pop up a dialog box which lists all available PowerShell language samples by default.  You can additionally enter a search term and
 click the "Search" button to additionally filter the list.
 
 Select any sample from the list and click the "Insert in Editor" button to insert the given sample code at the location of the cursor in the editor that had
 focus when the dialog was opened (yes, it doesn't work to select another editor after the dialog is opened, sorry).
 
 If you click "OK" the sample content is pasted in the shell.  "Cancel" simply closes the window.


To see a list of available functions:

Get-Command -Module SampleExchangePowerCLI

                      

**Nested Modules**
