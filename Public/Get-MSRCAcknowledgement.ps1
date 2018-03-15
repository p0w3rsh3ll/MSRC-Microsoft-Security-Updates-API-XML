Function Get-MSRCAcknowledgement {
<#
    .SYNOPSIS
        Get the acknowledgements from the MSRC portal

    .DESCRIPTION
       Get the acknowledgements from the MSRC portal

    .EXAMPLE
        Get-MSRCAcknowledgement

    .EXAMPLE
        Get-MSRCAcknowledgement -Year 2017

    .NOTES
        Misc: No API key required for this function

#>
[CmdletBinding()]    
Param(

    [Parameter()]
    [string]$Year = (Get-Date).ToString('yyyy')

)
Begin {

    $HT = @{
        URI = "https://portal.msrc.microsoft.com/api/security-guidance/en-us/acknowledgments/year/$($year)"
        Method = 'GET'
        UseBasicParsing = [switch]::Present
        UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0'
        Headers = @{
            Host ='portal.msrc.microsoft.com'
            Accept = 'application/json, text/plain, */*'
            'Accept-Language' = 'en-US,en;q=0.5'
            'Accept-Encoding' = 'gzip, deflate, br'
        }
        ErrorAction = 'Stop'
    }

}
Process {
    try {
        (Invoke-RestMethod  @HT).Details | 
        ForEach-Object {
            [PSCustomObject]@{
                PublishedDate = $_.publishedDate
                CVE = $_.cveNumber
                Description = $_.cveTitle
                acknowledgment = $_.acknowledgments
            }
        }
    } catch {
        Write-Warning -Message "Failed because $($_.Exception.Message)"
    } 
}
End {}
}