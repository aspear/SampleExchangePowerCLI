<#

Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause

.SYNOPSIS
Add VMware Sample Exchange PowerShell samples as PowerShell ISE snippets

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

 $webClient = New-Object System.Net.WebClient


# Utility to convert HTML to text since it seems that the snippet display in ISE cannot handle
# HTML, and Sample Exchange uses HTML for the description.  This code was taken from 
# http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/ 
function Html-ToText { 
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


function Get-SampleExchangeSamples() {
    $samples = Invoke-RestMethod -Method Get -Uri $powerShellSamplesUrl
    return $samples
}

function Get-SampleExchangeSampleById( $sampleId ) {
    <# 
    .SYNOPSIS Get one particular sample by id
    #>
    $url = $sxServerBaseUrl + "/search/" + $sampleId
    $sample = Invoke-RestMethod -Method Get -Uri $url
    return $sample
}

function Get-SampleExchangeSampleBody( $sample ) {
    
    # A sample in Sample Exchange can have multiple files, but 
    # it doesn't really make sense to add these sorts of samples as 
    # snippets since we don't have a way of knowing which file is the 'right' 
    # one to grab.  So, we only add snippets for samples that have a single file

    if (!($sample.files.Count -eq 1)) {
        "SKIPPING http://developercenter.vmware.com/samples?id={0:D} '{1}'. It has multiple files." -f $sample.id, $sample.name
        return ''
    }

    # TODO additional validation of the sample?
    
    # there is only one file add this one
    "GETTING   http://developercenter.vmware.com/samples?id={0:D} '{1}'" -f $sample.id, $sample.name
            
    foreach ($file in $sample.files) {
        $fileNameOnly = [io.path]::GetFileName($file.path)
        if ($fileNameOnly.EndsWith('.ps1')) {
            
            #$localFilePath = '{0}\{1}' -f $downloadDir, $fileNameOnly
	        #'    downloading id={0:5} {1} to {2}' -f $file.id, $fileNameOnly, $localFilePath
            $fileUrl = '{0}/downloads/sampleFile/{1}' -f $sxServerBaseUrl, $file.id
            
            $sampleFileBody = $webClient.DownloadString( $fileUrl )
            return $sampleFileBody           
        }
    }     
}


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
            
            #$localFilePath = '{0}\{1}' -f $downloadDir, $fileNameOnly
	        #'    downloading id={0:5} {1} to {2}' -f $file.id, $fileNameOnly, $localFilePath
            $fileUrl = '{0}/downloads/sampleFile/{1}' -f $sxServerBaseUrl, $file.id
            #$webClient.DownloadFile( $fileUrl, $localFilePath )

            $sampleFileBody = $webClient.DownloadString( $fileUrl )
            $title = 'VMW SE: {0}' -f $sample.name
            $description = Html-ToText( $sample.readmeHtml )
        
            New-ISESnippet -Text $sampleFileBody -Title $title -Description $description -Author $sample.author.fullName -Force
        }
    }     
}


function Add-SampleExchangeSnippets() {
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
      PS> Add-SampleExchangeSnippets  

    #>

    param()
       
    process{ 
        # make web service call to fetch the list of samples
        $samples = Get-SampleExchangeSamples
               
        foreach ($sample in $samples) {
            Add-SampleAsISESnippet $sample    
        }  

        "Snippets were added to {0}{1}\Documents\WindowsPowerShell\Snippets" -f $env:HOMEDRIVE, $env:HOMEPATH
    }
}

#  Call this line to add all samples

#$s = Get-SampleExchangeSampleById 871
#SampleExchangeSampleBody $s

