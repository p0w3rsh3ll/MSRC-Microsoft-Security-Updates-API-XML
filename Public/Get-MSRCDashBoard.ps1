Function Get-MSRCDashBoard {
<#
    .SYNOPSIS
        Get the dashboard page from the MSRC portal

    .DESCRIPTION
       Get the dashboard page from the MSRC portal

    .EXAMPLE
        Get-MSRCDashBoard

    .EXAMPLE
        Get-MSRCDashBoard -After 01/01/2018 -Before 01/31/2018


    .EXAMPLE 
        Get-MSRCDashBoard |
        Export-Csv -Path ~/Documents/MSRCDashBoard.$((Get-Date).ToString('yyyy-MM')).csv

        Import-CSV ~/Documents/MSRCDashBoard.$((Get-Date).ToString('yyyy-MM')).csv | 
        Out-GridView

    .EXAMPLE 
        Get-MSRCDashBoard -After 02/01/2018 -Before 02/28/2018 | 
        Select publishedDate,cveNumber,Name,Platform,severity,impact | 
        fl
    
    .EXAMPLE
        Get-MSRCDashBoard -After 02/01/2018 -Before 02/28/2018  |
        Select publishedDate,cveNumber,Name,Platform,articleTitle1,
        downloadTitle1,articleTitle2,downloadTitle2,severity,impact | 
        out-gridview

    .NOTES
        Misc: No API key required for this function

#>
[CmdletBinding()]
Param(
    [Parameter()]
    [DateTime]$After=((Get-Date).ToString('yyyy-MM-01')),

    [Parameter(ParameterSetName='ByDate')]
    [DateTime]$Before=((Get-Date).ToString('yyyy-MM-28'))
)
Begin {
    # Get page 1 and the count
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

    try {
        $Page1 = (Invoke-RestMethod  @HT)
    } catch {
        Write-Warning -Message "Failed because $($_.Exception.Message)"
    }         
}
Process {

    if ($Page1) {

        Write-Verbose -Message "Found $($Page1.Count) items"

        Try {
            $TotalPages = [Math]::Round($([int]$Page1.Count)/100) + 1
            Write-Verbose -Message "Found $($TotalPages) total pages"
        } catch {
            Write-Warning -Message "Failed because $($_.Exception.Message)"
        }

        if ($TotalPages) {

            $i = 0
            
            While ($i -ne $TotalPages) {

                $i++
            
                Write-Progress -Activity "Getting MSRC page $i" -PercentComplete (($i/$TotalPages)*100)
                
                Get-MSRCDashBoardPage -Page $i @PSBoundParameters
            }

            Write-Progress -Activity "Getting MSRC pages" -Completed

        }
    }
}
End {}
}