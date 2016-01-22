<#
Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause

.AUTHOR Aaron Spear, VMware Inc.

.SYNOPSIS
VMware Sample Exchange PowerShell integration

.DESCRIPTION
Uses Sample Exchange web services to query for the list of all PowerShell
scripts, then iterates this list adding those as PowerShell ISE snippets.
After this is done, you can access these snippets by hitting CTRL+J in 
PowerShell ISE to bring up the snippet insertion dialog.
#>

function Add-SampleAsISESnippet( $sample ) {
    
    # A sample in Sample Exchange can have multiple files, but 
    # it doesn't really make sense to add these sorts of samples as 
    # snippets since we don't have a way of knowing which file is the 'right' 
    # one to grab.  So, we only add snippets for samples that have a single file

    if (!($sample.files.Count -eq 1)) {
        "SKIPPING http://developercenter.vmware.com/samples?id={0:D} '{1}'. It has multiple files." -f $sample.id, $sample.name
        return
    }

    # TODO additional validation of the sample?
    
    # there is only one file add this one
    "ADDING   http://developercenter.vmware.com/samples?id={0:D} '{1}'" -f $sample.id, $sample.name
            
    foreach ($file in $sample.files) {
        $fileNameOnly = [io.path]::GetFileName($file.path)
        if ($fileNameOnly.EndsWith('.ps1')) {
                        
            $fileUrl = '{0}/downloads/sampleFile/{1}' -f $sxServerBaseUrl, $file.id
            
			$webClient = New-Object System.Net.WebClient
            $sampleFileBody = $webClient.DownloadString( $fileUrl )
            $title = 'VMW SE: {0}' -f $sample.name
            $description = Get-TextFromHtml( $sample.readmeHtml )
			
			# FIXME it seems that some samples have encoding that is not UTF-8 and this completely messes
			# up New-ISESnippet since it expects a string here.  We need to figure out how to convert arbitrary
			# character encoding to UTF-8 I guess?
        
            New-ISESnippet -Text $sampleFileBody -Title $title -Description $description -Author $sample.author.fullName -Force
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
