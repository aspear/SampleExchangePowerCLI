function Add-SampleExchangePowerShellISEAddonsMenu() {
   
    $SampleExchangeMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add( 
       "Sample Exchange",$null,$null) 
    $SampleExchangeMenu.SubMenus.Add("Sync Snippets", { Add-SampleExchangeSnippets } , $null)
    $SampleExchangeMenu.SubMenus.Add("Search Samples", { Show-SampleExchangeSearch } , $null) 
}

function Remove-SampleExchangePowerShellISEAddonsMenu() {
    #$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ClearMenu",  
    #     { $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear() }, $null)
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
}

Add-SampleExchangeToPowerShellISE