<#

Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause
#>

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
         [void] $objListBox.Items.Add($sample.name) 
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

#Show-SampleExchangeSearch


