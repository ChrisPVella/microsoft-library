<#
    .SYNOPSIS
    export-conditional-access-policies.ps1

    .DESCRIPTION
    Exports Microsoft Entra ID Conditional Access policies to JSON files for backup and review.

    .LINK
    https://github.com/ChrisPVella/microsoft-library

    .NOTES
    Author:     Chris Vella
    LinkedIn:   linkedin.com/in/chrispvella
#>

### Note: This script requires the Microsoft.Graph module to be installed. Uncomment or run the following line to install the module.
# Install-Module Microsoft.Graph -Force

# Connect to Microsoft Graph API
Connect-MgGraph -Scopes 'Policy.Read.All'

# Export path for CA policies
$ExportPath = "C:\Temp\CAPExport"

try {
    # Check if the export path exists and is writable
    if (!(Test-Path $ExportPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $ExportPath
    }

    # Retrieve all conditional access policies from Microsoft Graph API
    $AllPolicies = Get-MgIdentityConditionalAccessPolicy -All

    if ($AllPolicies.Count -eq 0) {
        Write-Output "There are no Conditional Access policies found to export."
    }
    else {
        # Iterate through each policy
        foreach ($Policy in $AllPolicies) {
            try {
                # Get the display name of the policy
                $PolicyName = $Policy.DisplayName
            
                # Convert the policy object to JSON with a depth of 6
                $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
            
                # Write the JSON to a file in the export path
                $PolicyName = $PolicyName -replace '[\\\/:*?"<>|]', '_' # Replace invalid characters with underscores
                $PolicyJSON | Out-File "$ExportPath\$PolicyName.json" -Force
            
                # Print a success message for the policy backup
                Write-Output "Successfully backed up Conditional Access policy: $($PolicyName)"
            }
            catch {
                # Print an error message for the policy backup
                Write-Output "Error occurred while backing up Conditional Access policy: $($Policy.DisplayName). $($_.Exception.Message)"
            }
        }
    }
}
catch {
    # Print a generic error message
    Write-Output "Error occurred: $($_.Exception.Message)"
}