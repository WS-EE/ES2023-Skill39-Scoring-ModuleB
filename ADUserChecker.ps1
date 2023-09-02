param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("dk.skill39.wse", "pl.skill39.wse")]
    [string]$Domain,

    [Parameter(Mandatory=$true)]
    [string]$CsvFilePath
)

$CsvData = Import-Csv -Path $CsvFilePath
$Discrepancies = @()
$OuCounts = @{}

foreach ($Row in $CsvData) {
    if ($Row.domain -eq $Domain) {
        $SamAccountName = ""

        switch ($Domain) {
            "dk.skill39.wse" {
                if ($Row.last_name.Length -ge 3) {
                    $SamAccountName = ($Row.last_name).Substring(0, 3) + "." + $Row.first_name
                } else {
                    $SamAccountName = $Row.last_name + "." + $Row.first_name
                }
            }
            "pl.skill39.wse" {
                if ($Row.first_name.Length -ge 2) {
                    $SamAccountName = ($Row.first_name).Substring(0, 2) + "." + $Row.last_name
                } else {
                    $SamAccountName = $Row.first_name + "." + $Row.last_name
                }
            }
        }

        try {
            $AdUser = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -Properties DistinguishedName, EmailAddress, GivenName, Surname, Company, City, Department, Title
            
            # Check if the user exists
            if ($null -eq $AdUser) {
                $Discrepancies += "User with SAMAccountName $SamAccountName not found in AD."
                continue
            }

            # Compare each field
            if ($AdUser.GivenName -ne $Row.first_name) { $Discrepancies += "Mismatched first name for $SamAccountName. Actual: $($AdUser.GivenName), Expected: $($Row.first_name)" }
            if ($AdUser.Surname -ne $Row.last_name) { $Discrepancies += "Mismatched last name for $SamAccountName. Actual: $($AdUser.Surname), Expected: $($Row.last_name)" }
            if ($AdUser.Company -ne $Row.company) { $Discrepancies += "Mismatched company for $SamAccountName. Actual: $($AdUser.Company), Expected: $($Row.company)" }
            if ($AdUser.City -ne $Row.city) { $Discrepancies += "Mismatched city for $SamAccountName. Actual: $($AdUser.City), Expected: $($Row.city)" }
            if ($AdUser.Department -ne $Row.department) { $Discrepancies += "Mismatched department for $SamAccountName. Actual: $($AdUser.Department), Expected: $($Row.department)" }
            if ($AdUser.Title -ne $Row.job) { $Discrepancies += "Mismatched job title for $SamAccountName. Actual: $($AdUser.Title), Expected: $($Row.job)" }

            # Get the OU from the user's DistinguishedName
            if ($AdUser) {
                $Ou = ($AdUser.DistinguishedName -split ',', 2)[1]

                # Increment the count for this OU
                if ($OuCounts.ContainsKey($Ou)) {
                    $OuCounts[$Ou]++
                } else {
                    $OuCounts[$Ou] = 1
                }
            }
        }
        catch {
            $Discrepancies += "Error processing $($SamAccountName): $_"
        }
    }
}

# Output discrepancies
$Discrepancies | ForEach-Object { Write-Host $_ }

# Output user counts in OUs
Write-Host "Users are located in these OUs:"
$OuCounts.Keys | ForEach-Object {
    $Ou = $_
    $Count = $OuCounts[$Ou]
    Write-Host "$($Ou): $Count"
}
