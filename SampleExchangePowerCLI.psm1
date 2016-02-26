<#
Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause
Please feel free to do something creative with it!

.AUTHOR Aaron Spear, VMware Inc.

.SYNOPSIS
VMware Sample Exchange PowerShell/PowerCLI integration

.DESCRIPTION
cmdlets and functions to access VMware Sample Exchange services.  There are 
a number of utility methods to search/get lists, and download samples from
sample exchange, and then other methods meant to be consumed by end users
listed below:

Show-SampleExchangeSearch : Puts up a dialog box and allows searching and 
selecting PowerShell scripts.  Selected scripts can be pasted at the current
line in PowerShell ISE or pasted on a shell.

Sync-SampleExchangeSnippetsWithISE : Synchronizes all Sample Exchange 
PowerShell scripts to be available via the PowerShell ISE snippets
feature.  After doing this,hitting CTRL+J in PowerShell ISE to bring
up the snippet insertion dialog will allow pasting samples.

#>

<# 
 Utility to convert HTML to text since it seems that the snippet display in ISE cannot handle
 HTML, and Sample Exchange uses HTML for the description.  This code was taken from 
 http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/ 
 #>
function Get-TextFromHtml { 
     param([System.String] $html) 
 
     # remove line breaks, replace with spaces 
     $html = $html -replace "(`r|`n|`t)", " " 
     # write-verbose "removed line breaks: `n`n$html`n" 
 
     # remove invisible content 
     @('head', 'style', 'script', 'object', 'embed', 'applet', 'noframes', 'noscript', 'noembed') | % { 
      $html = $html -replace "<$_[^>]*?>.*?</$_>", "" 
     } 
     # write-verbose "removed invisible blocks: `n`n$html`n" 
 
     # Condense extra whitespace 
     $html = $html -replace "( )+", " " 
     # write-verbose "condensed whitespace: `n`n$html`n" 
 
     # Add line breaks 
     @('div','p','blockquote','h[1-9]') | % { $html = $html -replace "</?$_[^>]*?>.*?</$_>", ("`n" + '$0' )}  
     # Add line breaks for self-closing tags 
     @('div','p','blockquote','h[1-9]','br') | % { $html = $html -replace "<$_[^>]*?/>", ('$0' + "`n")}  
     # write-verbose "added line breaks: `n`n$html`n" 
 
     #strip tags  
     $html = $html -replace "<[^>]*?>", "" 
     # write-verbose "removed tags: `n`n$html`n" 
   
     # replace common entities 
     @(  
      @("&amp;bull;", " * "), 
      @("&amp;lsaquo;", "<"), 
      @("&amp;rsaquo;", ">"), 
      @("&amp;(rsquo|lsquo);", "'"), 
      @("&amp;(quot|ldquo|rdquo);", '"'), 
      @("&amp;trade;", "(tm)"), 
      @("&amp;frasl;", "/"), 
      @("&amp;(quot|#34|#034|#x22);", '"'), 
      @('&amp;(amp|#38|#038|#x26);', "&amp;"), 
      @("&amp;(lt|#60|#060|#x3c);", "<"), 
      @("&amp;(gt|#62|#062|#x3e);", ">"), 
      @('&amp;(copy|#169);', "(c)"), 
      @("&amp;(reg|#174);", "(r)"), 
      @("&amp;nbsp;", " "), 
      @("&amp;(.{2,6});", "") 
     ) | % { $html = $html -replace $_[0], $_[1] } 
     # write-verbose "replaced entities: `n`n$html`n" 
 
     return $html  
}


#############################################################################
##
## Set-Clipboard
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################
function Set-Clipboard {
    <#

    .SYNOPSIS

    Sends the given input to the Windows clipboard.

    .EXAMPLE

    dir | Set-Clipboard
    This example sends the view of a directory listing to the clipboard

    .EXAMPLE

    Set-Clipboard "Hello World"
    This example sets the clipboard to the string, "Hello World".

    #>

    param(
        ## The input to send to the clipboard
        [Parameter(ValueFromPipeline = $true)]
        [object[]] $InputObject
    )

    begin
    {
        Set-StrictMode -Version Latest
        $objectsToProcess = @()
    }

    process
    {
        ## Collect everything sent to the script either through
        ## pipeline input, or direct input.
        $objectsToProcess += $inputObject
    }

    end
    {
        ## Launch a new instance of PowerShell in STA mode.
        ## This lets us interact with the Windows clipboard.
        $objectsToProcess | PowerShell -NoProfile -STA -Command {
            Add-Type -Assembly PresentationCore

            ## Convert the input objects to a string representation
            $clipText = ($input | Out-String -Stream) -join "`r`n"

            ## And finally set the clipboard text
            [Windows.Clipboard]::SetText($clipText)
        }
    }
}

# Base URL for Sample Exchange REST services
$sxServerBaseUrl = "https://vdc-repo.vmware.com/sampleExchange/rest"

# URL to fetch only PowerShell samples
$powerShellSamplesUrl= $sxServerBaseUrl + "/search/samples/tag/category/Language/name/PowerShell"

function Get-SampleExchangeSamples() {
	<#
	.SYNOPSIS Call Sample Exchange Web services to get all PowerShell language samples
	
	.INPUTS None.
	
	.OUTPUT A list of Sample Exchange Sample Objects.  Documentation to come	
	#>
    
	# Sample Exchange web services return a list of samples in JSON.  Happily Invoke-RestMethod
	# automatically translates this into .NET objects for us so we can seamlessly access the samples
	$samples = Invoke-RestMethod -Method Get -Uri $powerShellSamplesUrl
    return $samples
}

function Get-SampleExchangeSampleById( $sampleId ) {
    <# 
    .SYNOPSIS Get one particular sample by integer id
    .INPUTS sampleId - integer sample id	
	.OUTPUT Sample object
    #>
    $url = $sxServerBaseUrl + "/search/samples/" + $sampleId
    $sample = Invoke-RestMethod -Method Get -Uri $url
    return $sample
}

function Get-SampleExchangeSampleBody( $sample ) {
    <#
	.SYNOPSIS Get the text body for a particular sample object
	
	.DESCRIPTION Get the body of a sample as plain text.  Sample Exchange does support samples having multiple files,
	so in that case all files are scanned to see if there happens to only be one .ps1 file and if this is the case it is 
	returned.  In the case that there are multiple, null is returned.
	
	.PARAMATER sample
    Sample object to get the body for
	
	.OUTPUT the body of the sample as plain text.  If the sample has multiple files this will be null.
 	
	#>
	
    # A sample in Sample Exchange can have multiple files, but 
    # it doesn't really make sense to add these sorts of samples as 
    # snippets since we don't have a way of knowing which file is the 'right' 
    # one to grab.  So, we only add snippets for samples that have a single file

    if ($sample.files.Count -eq 0) {       
        return $null
    }
	$ps1FileCount = 0
	foreach ($file in $sample.files) {
	    $fileNameOnly = [io.path]::GetFileName($file.path)
        if ($fileNameOnly.EndsWith('.ps1')) {
		    $ps1FileCount++
		}
	}
	
	if (!($ps1FileCount -eq 1)) {
	    #"SAMPLE HAS TOO MANY FILES: http://developercenter.vmware.com/samples?id={0:D} '{1}'" -f $sample.id, $sample.name
		return $null
	}
		  
    # there is only one file of ps1 extension, return it    
            
    foreach ($file in $sample.files) {
        $fileNameOnly = [io.path]::GetFileName($file.path)
        if ($fileNameOnly.EndsWith('.ps1')) {
		             
            #$localFilePath = '{0}\{1}' -f $downloadDir, $fileNameOnly
	        #'    downloading id={0:5} {1} to {2}' -f $file.id, $fileNameOnly, $localFilePath
            $fileUrl = '{0}/downloads/sampleFile/{1}' -f $sxServerBaseUrl, $file.id
            
            $webClient = New-Object System.Net.WebClient
			$sampleFileBody = $webClient.DownloadString( $fileUrl )
            return $sampleFileBody           
        }
    }     
}

function Sync-SampleExchangeSnippetsWithISE() {
    <#  
    .SYNOPSIS  
      Adds all PowerShell samples from VMware Sample Exchange
      as snippets in PowerShell ISE 4+
    .DESCRIPTION 
        Uses Sample Exchange web services to query for the list of all PowerShell
        scripts, then iterates this list adding those as PowerShell ISE snippets.
        After this is done, you can access these snippets by hitting CTRL+J in 
        PowerShell ISE to bring up the snippet insertion dialog.
    .EXAMPLE
      PS> Sync-SampleExchangeSnippetsWithISE 

    #>

    param()
       
    process{ 
        # make web service call to fetch the list of samples
        $samples = Get-SampleExchangeSamples
               
        foreach ($sample in $samples) {
				   
            $title = 'VMW SE: {0}' -f $sample.name
            $description = Get-TextFromHtml( $sample.readmeHtml )
			$sampleFileBody = Get-SampleExchangeSampleBody $sample
					
			if ([string]::IsNullOrEmpty($sampleFileBody)) {
				"SKIPPING http://developercenter.vmware.com/samples?id={0:D} '{1}'. It has multiple files or is empty." -f $sample.id, $sample.name				  
			} else {

                "SYNCING  http://developercenter.vmware.com/samples?id={0:D} '{1}'" -f $sample.id, $sample.name
			
				# FIXME it seems that some samples have encoding that is not UTF-8 and this completely messes
				# up New-ISESnippet since it expects a string here.  We need to figure out how to convert arbitrary
				# character encoding to UTF-8 I guess?
			
				New-ISESnippet -Text $sampleFileBody -Title $title -Description $description -Author $sample.author.fullName -Force  			
			}   
        }  

        "Snippets were added to {0}{1}\Documents\WindowsPowerShell\Snippets" -f $env:HOMEDRIVE, $env:HOMEPATH
    }
}

function Show-SampleExchangeSearch() {
    <#
    .SYNOPSIS Show a selection dialog for VMware Sample Exchange samples.  Allow insertion into active PowerShell ISE editor or print selection to the terminal.
    .DESCRIPTION Uses VMware Sample Exchange web services to query for available PowerCLI samples.  Once you select one, you can 
    optionally insert it directly in the currently selected editor, or return it to the shell.
    #>

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Search for samples"
    $objForm.Size = New-Object System.Drawing.Size(600,400) 
    $objForm.StartPosition = "CenterScreen"
    
    $objForm.KeyPreview = $True
       $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
        {$objForm.Close()}})

    $SampleToEditorButton = New-Object System.Windows.Forms.Button
    $SampleToEditorButton.Location = New-Object System.Drawing.Size(10,334)
    $SampleToEditorButton.Size = New-Object System.Drawing.Size(100,23)
    $SampleToEditorButton.Text = "Insert in Editor"
    $SampleToEditorButton.Add_Click(
     {
         $selectedSample = $samples.Get($objListBox.SelectedIndex)
         #$sampleText = "selected sample id={0} name='{1}'" -f $selectedSample.id, $selectedSample.name
         #$sampleText 
         $sampleBody = Get-SampleExchangeSampleBody $selectedSample
         $psISE.CurrentFile.Editor.InsertText($sampleBody)
     })
    $objForm.Controls.Add($SampleToEditorButton)

    
    $SampleToClipboardButton = New-Object System.Windows.Forms.Button
    $SampleToClipboardButton.Location = New-Object System.Drawing.Size(112,334)
    $SampleToClipboardButton.Size = New-Object System.Drawing.Size(110,23)
    $SampleToClipboardButton.Text = "Copy to Clipboard"
    $SampleToClipboardButton.Add_Click(
     {
         $selectedSample = $samples.Get($objListBox.SelectedIndex)
         $sampleBody = Get-SampleExchangeSampleBody $selectedSample
         #[Windows.Clipboard]::SetText($sampleBody)
         Set-Clipboard $sampleBody
         
     })
    $objForm.Controls.Add($SampleToClipboardButton)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(420,334)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"


    # Got rid of the Click event for the OK button, and instead just assigned its DialogResult property to OK.
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

    $objForm.Controls.Add($OKButton)

    # Setting the form's AcceptButton property causes it to automatically intercept the Enter keystroke and
    # treat it as clicking the OK button (without having to write your own KeyDown events).
    $objForm.AcceptButton = $OKButton
    
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(496,334)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"

    # Got rid of the Click event for the Cancel button, and instead just assigned its DialogResult property to Cancel.
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $objForm.Controls.Add($CancelButton)

    # Setting the form's CancelButton property causes it to automatically intercept the Escape keystroke and
    # treat it as clicking the OK button (without having to write your own KeyDown events).
    $objForm.CancelButton = $CancelButton

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,5) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = "Search query:"
    $objForm.Controls.Add($objLabel) 

    $searchTextBox = New-Object System.Windows.Forms.TextBox 
    $searchTextBox.Location = New-Object System.Drawing.Size(10,25) 
    $searchTextBox.Size = New-Object System.Drawing.Size(350,5) 
    $objForm.Controls.Add($searchTextBox) 
    
    $searchSubmitButton = New-Object System.Windows.Forms.Button
    $searchSubmitButton.Location = New-Object System.Drawing.Size(365,25)
    $searchSubmitButton.Size = New-Object System.Drawing.Size(100,23)
    $searchSubmitButton.Text = "Search"    
    #$searchSubmitButton.IsDefault = true  #FIXME why isn't this available?
    $searchSubmitButton.Add_Click(
     {
        $objListBox.BeginUpdate()
        $objListBox.Items.Clear()

        $searchText = $searchTextBox.Text.Trim()

        # FIXME implement a real search here using a service call
        $samples = Get-SampleExchangeSamples

         foreach ($sample in $samples) {        
        
              if (  ($searchText.Length -eq 0) -or ($sample.name.Contains( $searchText ) -or $sample.readmeHtml.Contains( $searchText ))) {
              #if (  ($searchText.Length -eq 0)) {
                  [void] $objListBox.Items.Add($sample.name)
              }              
         }

        $objListBox.EndUpdate()
         
     })
    $objForm.Controls.Add($searchSubmitButton)
    
    $objListBox = New-Object System.Windows.Forms.ListBox 
    $objListBox.Location = New-Object System.Drawing.Size(10,50) 
    $objListBox.Size = New-Object System.Drawing.Size(560,20) 
    $objListBox.Height = 289

    $samples = Get-SampleExchangeSamples

     foreach ($sample in $samples) {
         if ( $sample.name ) {
						[void] $objListBox.Items.Add($sample.name) 
				 }
     }

    $objForm.Controls.Add($objListBox) 

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})

    # when the user selects OK, print the body of the sample in the console.
    $result = $objForm.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $objListBox.SelectedIndex -ge 0)
    {
        $selection = $objListBox.SelectedItem
        #$selection

        $selectedSample = $samples.Get($objListBox.SelectedIndex)

         #"selected sample id={0} name='{1}'" -f $selectedSample.id, $selectedSample.name
         $sampleBody = Get-SampleExchangeSampleBody $selectedSample

         #dump the sample body out to stdout
         $sampleBody
    }
}

function Remove-SampleExchangePowerShellISEAddonsMenu() {
    if ($psISE) {  
	    #$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ClearMenu",  
        #     { $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear() }, $null)
        $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
	}
}

function Add-SampleExchangePowerShellISEAddonsMenu() {
<# Method that only has to be executed once at module startup in order to add the menu items
for sample exchange to PowerShell ISE #>   
    if ($psISE) { 	    
        "Adding Sample Exchange commands to PowerShell ISE Add-Ons menu."	
		$SampleExchangeMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add( 
		   "VMware Sample Exchange",$null,$null) 
		$SampleExchangeMenu.SubMenus.Add("Sync Snippets", { Sync-SampleExchangeSnippetsWithISE } ,$null)
		$SampleExchangeMenu.SubMenus.Add("Search Samples", { Show-SampleExchangeSearch } , "Ctrl+Shift+s") 
	}
}

# Call at module init in order to add to PowerShell ISE
Add-SampleExchangePowerShellISEAddonsMenu
