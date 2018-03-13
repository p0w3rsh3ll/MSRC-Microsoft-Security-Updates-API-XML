Function Get-MSRCReleaseNotePage {
<#
    .SYNOPSIS
        Get the latest release notes page from the MSRC portal

    .DESCRIPTION
       Get the latest release notes page from the MSRC portal

    .EXAMPLE
        Get-MSRCReleaseNotePage -Id 879af9c3-970b-e811-a961-000d3a33c573

    .EXAMPLE 
        Get-MSRCReleaseNoteId | Get-MSRCReleaseNotePage

    .EXAMPLE 
        '879af9c3-970b-e811-a961-000d3a33c573' | Get-MSRCReleaseNotePage | fl

    .NOTES
        Misc: No API key required for this function

#>
[CmdletBinding()]    
Param(
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [String]$Id
)
Begin {
    $root = 'https://portal.msrc.microsoft.com/api/security-guidance/en-us/releaseNotedetail'
}
Process {

    $HT = @{
        UseBasicParsing = [switch]::Present
        Uri = '{0}/{1}' -f $root,$Id
        Method =  'Get'
        UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0'
        Headers = @{
            Host ='portal.msrc.microsoft.com'
            Accept = 'application/json, text/plain, */*'
            'Accept-Language' = 'en-US,en;q=0.5'
            'Accept-Encoding' = 'gzip, deflate, br'
        }
        ErrorAction = 'Stop'
    }
    try {
        Invoke-RestMethod @HT | 
        ForEach-Object {
            [PSCustomObject]@{
                Id = $_.id
                Title = $_.shipVehicleTitle
                ReleaseDate = $_.releaseDate
                Notes = $_.notes
            }
        }
    } catch {
        Write-Warning -Message "Failed because $($_.Exception.Message)"
    } 
}
End {}
}