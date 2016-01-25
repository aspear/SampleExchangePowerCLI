<#
Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause

.AUTHOR Aaron Spear, VMware Inc.

.DESCRIPTION A couple of utility methods to add menu options to 
PowerShell ISE for Sample Exchange

#>

function Remove-SampleExchangePowerShellISEAddonsMenu() {
    if ($psISE) {  
	    #$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ClearMenu",  
        #     { $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear() }, $null)
        $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
	}
}

function Add-SampleExchangePowerShellISEAddonsMenu() {

    Remove-SampleExchangePowerShellISEAddonsMenu

    # only do this if we are in PowerShell ISE...
    if ($psISE) { 
        "Adding Sample Exchange commands to PowerShell ISE Add-Ons menu."	
		$SampleExchangeMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add( 
		   "VMware Sample Exchange",$null,$null) 
		$SampleExchangeMenu.SubMenus.Add("Sync Snippets", { Sync-SampleExchangeSnippetsWithISE } ,$null)
		$SampleExchangeMenu.SubMenus.Add("Search Samples", { Show-SampleExchangeSearch } , "Ctrl+Shift+s") 
	}
}

Add-SampleExchangePowerShellISEAddonsMenu