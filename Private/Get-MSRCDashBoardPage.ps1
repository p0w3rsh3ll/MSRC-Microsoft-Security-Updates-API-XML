Function Get-MSRCDashBoardPage {
<#
    .SYNOPSIS
        Get a specific dashboard page from the MSRC portal

    .DESCRIPTION
       Get a specific dashboard page from the MSRC portal

    .EXAMPLE
        Get-MSRCDashBoardPage -Page 1

    .EXAMPLE
        Get-MSRCDashBoardPage -Page 3 -After 01/01/2018 -Before 01/31/2018

    .NOTES
        Misc: No API key required for this function

#>
[CmdletBinding()]    
Param(
    [Parameter()]
    [int]$Page=1,

    [Parameter()]
    [DateTime]$After=((Get-Date).ToString('yyyy-MM-01')),

    [Parameter(ParameterSetName='ByDate')]
    [DateTime]$Before=((Get-Date).ToString('yyyy-MM-28'))
)
Begin {
    $rBody = @"
{
    "familyIds":[],
    "productIds":[],
    "severityIds":[],
    "impactIds":[],
    "pageNumber":$($Page),
    "pageSize":100,
    "includeCveNumber":true,
    "includeSeverity":true,
    "includeImpact":true,
    "includeMonthly":true,
    "orderBy":"publishedDate",
    "orderByMonthly":"releaseDate",
    "isDescending":true,
    "isDescendingMonthly":true,
    "queryText":"",
    "isSearch":false,
    "filterText":"",
    "fromPublishedDate":"$($After.ToString('MM/dd/yyyy'))",
    "toPublishedDate":"$($Before.ToString('MM/dd/yyyy'))"
}
"@

    $HT = @{
        URI = 'https://portal.msrc.microsoft.com/api/security-guidance/en-us'
        Method = 'POST'
        Body = $rBody
        UseBasicParsing = $true
        ContentType = 'application/json'
        UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0'
        Headers = @{
            Host ='portal.msrc.microsoft.com'
            Accept = 'application/json, text/plain, */*'
            'Accept-Language' = 'en-US,en;q=0.5'
            'Accept-Encoding' = 'gzip, deflate, br'
        }
    }
}
Process {
    try {
        (Invoke-RestMethod  @HT).Details
    } catch {
        Write-Warning -Message "Failed because $($_.Exception.Message)"
    } 
}
End {}
}