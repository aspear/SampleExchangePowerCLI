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

# Base URL for Sample Exchange REST services for the internal STAGING server.
#$sxServerBaseUrl = "https://dc-stg-repo1.vmware.com:8443/sampleExchange/rest"

# Base URL for Sample Exchange REST services
$sxServerBaseUrl = "https://vdc-repo.vmware.com/sampleExchange/rest"

# URL to fetch only PowerShell samples
$powerShellSamplesUrl= $sxServerBaseUrl + "/search/tag/category/Language/name/PowerShell"

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
    $url = $sxServerBaseUrl + "/search/" + $sampleId
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

#Get-SampleExchangeSampleBody( Get-SampleExchangeSampleById(594) )
