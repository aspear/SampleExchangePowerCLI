# SampleExchangePowerCLI Module

A PowerShell Module that contains integration between [VMware's new sample code repository Sample Exchange](http://developercenter.vmware.com/samples), 
 and PowerShell ISE.  Sample Exchange contains an ever growing catalog of PowerCLI samples and snippets, and this module uses Sample Exchange REST
 web services to allow a user to paste sample code into their editors directly in PowerShell ISE.

**Pre-Requisites**

PowerShell version 4 or later.

**Installation**

1) Download (or clone) all files comprising the module.

2) Create a folder for the module in your module folder path, e.g. C:\Users\username\Documents\WindowsPowerShell\Modules\SampleExchangePowerCLI

3) Place the module files in the above folder.  The SampleExchangePowerCLI.psd1 and SampleExchangePowerCLI.psm1 files should be in the root of the folder 

NOTE: If you create the folder in the path above, then PowerShell ISE (and regular PowerShell windows) will load the module.  
 If you don't want to do this, you can manually install the module by running the command

 PS C:\> Import-Module -Force -Verbose C:\local\path\where\you\extracted\SampleExchangePowerCLI
 
 where SampleExchangePowerCLI is the folder containing SampleExchangePowerCLI.psd1 and SampleExchangePowerCLI.psm1.
 
 4) Restart PowerShell ISE
 
 5) If you would like to have Sample Exchange samples available via the PowerShell ISE Snippets feature, Go to "Add-ons" > "Sample Exchange" > "Sync Snippets"
 
 This command is the equivilent of calling the "Sync-SampleExchangeSnippetsWithISE" method directly.  It downloads all samples and registers them as "Snippets" 
 in PowerShell ISE thus making them available for use in the editor when you issue the "CTRL + J" hot-key.  
 
 If you later decide that you do not like this, you can simply go to C:\Users\<user>\Documents\WindowsPowerShell\Snippets and delete all of the VMW*.ps1xml files
 and the snippets will go away. 
 
**Usage**

Selecting Either Add-ons > VMware Sample Exchange > Search Samples, or hitting "CTRL + SHIFT + S" will bring up a dialog box which lists all available 
 PowerShell language samples by default.  You can additionally enter a search term and
 click the "Search" button to additionally filter the list.
 
 Select any sample from the list and click the "Insert in Editor" button to insert the given sample code at the location of the cursor in the editor that had
 focus when the dialog was opened (yes, it doesn't work to select another editor after the dialog is opened, sorry).
 
 If you click "OK" the sample content is pasted in the shell.  "Cancel" simply closes the window.

To see a list of available functions:

Get-Command -Module SampleExchangePowerCLI
