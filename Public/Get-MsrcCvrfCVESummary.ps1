Function Get-MsrcCvrfCVESummary {
<#
    .SYNOPSIS
        Get the CVE summary from vulnerabilities found in CVRF document

    .DESCRIPTION
       This function gathers the CVE Summary from vulnerabilities in a CVRF document.

    .PARAMETER cvrfDocument
        A CVRF document object or objects in XML format

    .EXAMPLE
        Get-MsrcCvrfXMLDocument -ID 2016-Nov | Get-MsrcCvrfCVESummary
   
        Get the CVE summary from a CVRF document using the pipeline.
   
    .EXAMPLE
        Get-MsrcCvrfCVESummary -cvrfDocument (Get-MsrcCvrfXMLDocument -ID 2016-Nov)

        Get the CVE summary from a CVRF document using a variable and parameters
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory,ValueFromPipeline)]
    $cvrfDocument
)
Begin {
    Function Get-MaxSeverity {
    [CmdletBinding()]
    [OutputType('System.String')]
    Param($InputObject)
    Begin {}
    Process {
        if ('Critical' -in $InputObject) {
            'Critical'
        } elseif ('Important' -in $InputObject) {
            'Important'
        } elseif ('Moderate' -in $InputObject) {
            'Moderate'
        } elseif ('Low' -in $InputObject) {
            'Low'
        } else {
            'Unknown'
        }
    }
    End {}
    }
}
Process {
    $cvrfDocument | 
    ForEach-Object {

        Write-Verbose -Message "Dealing with document:'$($_.cvrfdoc.DocumentTitle)'"
        $doc = $_.cvrfdoc
        $doc.Vulnerability |
        ForEach-Object {

            $v = $_

            [PSCustomObject]@{
                CVE = $v.CVE
                Description = $(
                     ($v.Notes.Note | Where-Object { $_.Title -eq 'Description' }).'#text'
                ) ;
                'Maximum Severity Rating' = $(
                    Get-MaxSeverity ($v.Threats.Threat | Where-Object {$_.Type -eq 'Severity' } ).Description
                ) ;
                'Vulnerability Impact' = $(
                    ($v.Threats.Threat | Where-Object {$_.Type -eq 'Impact' }).Description | Select-Object -Unique
                ) ;
                'Affected Software' = $(
                    (Get-MSRCProduct -ID $v.ProductStatuses.Status.ProductID).Name
                )
                # 'Affected Software' = $(
                #     $v.ProductStatuses.Status.ProductID | 
                #     ForEach-Object {
                #         $id = $_
                #         ($doc.ProductTree.FullProductName | Where-Object { $_.ProductID -eq $id}).'#text'
                #     }
                # ) ;
            }
        }
    }
}
End {}
}