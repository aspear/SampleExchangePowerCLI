<#
Copyright 2016 VMware Inc.  All Rights Reserved.

This file is released as open source under the terms of the 
BSD 3-Clause license: https://opensource.org/licenses/BSD-3-Clause

.AUTHOR Aaron Spear, VMware Inc.

.SYNOPSIS
VMware Sample Exchange PowerShell integration
#>

@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'SampleExchangePowerCLI.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '201eb4aa-cdd2-4c00-818b-bfc609b4adc0'

# Author of this module
Author = 'Aaron Spear'

# Company or vendor of this module
CompanyName = 'VMware'

# Copyright statement for this module
Copyright = '(c) 2016 VMware Inc, All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell module to synchronize PowerShell snippets from VMware Sample Exchange'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
#ScriptsToProcess = ''

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
#FormatsToProcess = ''

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
#NestedModules = ''

# Functions to export from this module
FunctionsToExport = 'Get-SampleExchangeSample',
                    'Get-SampleExchangeSampleBody',
                    'Sync-SampleExchangeSnippetsWithISE',
					'Show-SampleExchangeSearch'					

# Cmdlets to export from this module
CmdletsToExport = 'Sync-SampleExchangeSnippetsWithISE','Show-SampleExchangeSearch'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

