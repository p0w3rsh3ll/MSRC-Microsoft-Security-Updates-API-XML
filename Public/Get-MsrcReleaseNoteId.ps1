Function Get-MSRCReleaseNoteId {
<#
    .SYNOPSIS
        Get the latest release notes from the MSRC portal

    .DESCRIPTION
       Get the latest release notes from the MSRC portal

    .EXAMPLE
        Get-MSRCReleaseNoteId
   
        Id                                   Title                          ReleaseDate        
        --                                   -----                          -----------        
        879af9c3-970b-e811-a961-000d3a33c573 February 2018 Security Updates 2018-02-13T08:00:00

    .NOTES
        Misc: No API key required for this function

#>
[CmdletBinding()]    
Param()
Begin {

    [datetime]$After= (Get-Date).ToString('yyyy-MM-01')

    [datetime]$Before= (Get-Date).ToString('yyyy-MM-28')

    $rBody = @"
{
    "familyIds":[],
    "productIds":[],
    "severityIds":[],
    "impactIds":[],
    "pageNumber":1,
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
        UseBasicParsing = [switch]::Present
        Uri = 'https://portal.msrc.microsoft.com/api/security-guidance/en-us/releaseNotes'
        Method =  'Post'
        Body = $rBody
        ErrorAction = 'Stop'
    }
}
Process {
    try {
        (Invoke-RestMethod  @HT).Details | 
        ForEach-Object {
            [PSCustomObject]@{
                Id = $_.id
                Title = $_.title
                ReleaseDate = $_.releaseDate
            }
        }
    } catch {
        Write-Warning -Message "Failed because $($_.Exception.Message)"
    } 
}
End {}
}
