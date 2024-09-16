<#
.SYNOPSIS
The main purpose of this script is to gather the Cortex XDR version present in an endpoint.

.DESCRIPTION
This script runs and checks the two directory declared as $directoryPaths, these paths are the location of the Cortex XDR security agent.

.NOTES
File Name      : CheckCortexXDRVersion.ps1
Prerequisite   : PowerShell

.EXAMPLE
.\CheckCortexXDRVersion.ps1

Q3JlYXRlZCBieSBGTzI=
#>

#create directory and log file
$datetime = (Get-Date).ToString('yyyyMMdd-hhmmtt')
Start-Transcript -Path "C:\cortex-xdr-version-$datetime.txt" -NoClobber

#sleep for 15 seconds to make sure that the start-transcript process will finish as expected
Start-Sleep -s 15

# Define the paths and filename
$directoryPaths = @("C:\Program Files\Palo Alto Networks\Traps","C:\Program Files (x86)\Palo Alto Networks\Traps")
$fileName = "cytray.exe"
$iniFileName = "SecurityProductInformation.ini"
$securityAgentInstalled = ""

# Function to read INI file and get the 'Version' key value
function Get-CortexInfo {
    param ([string]$directoryPath)

        $filePath = Join-Path -Path $directoryPath -ChildPath $fileName
        $fileIniPath = Join-Path -Path $directoryPath -ChildPath $iniFileName

        if (Test-Path $filePath) {
            if (Test-Path $fileIniPath) {
                try {
                    $iniData = @{}

                    # Read the INI file
                    $lines = Get-Content -Path $fileIniPath
                    foreach ($line in $lines) {
                        if ($line -match "^(.*)=(.*)$") {
                            $key = $matches[1].Trim()
                            $value = $matches[2].Trim()
                            $iniData[$key] = $value
                        }
                    }

                    # Check if 'Version' key exists
                    if ($iniData.ContainsKey("Version")) {
                        return $iniData["Version"]
                    }
                }
                catch {
                    return "An error occurred while reading the file: $_"
                }
            }
            else {
                return "SecurityProductInformation.ini not found."
            }
        }
    return $null
}

# Should iterate over the declared directory paths
foreach ($directoryPath in $directoryPaths) {
    $result = Get-CortexInfo -directoryPath $directoryPath
    if ($result) {
        $securityAgentInstalled = $result
        break
    }
}

# If no Cortex XDR then make the user know it
if (-not $securityAgentInstalled) {
    $securityAgentInstalled = "No Cortex XDR found."
}

# Output the result
Write-Host "Cortex XDR version is $securityAgentInstalled"
