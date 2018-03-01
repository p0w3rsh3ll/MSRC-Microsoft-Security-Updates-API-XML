Function Get-MsrcCvrfAffectedSoftware {
<#
    .SYNOPSIS
        Get details of products affected by a CVRF document

    .DESCRIPTION
       CVRF documents next products into several places, including:
       -Vulnerabilities
       -Threats
       -Remediations
       -Product Tree
       This function gathers the details for each product identified in a CVRF document.

    .PARAMETER cvrfDocument
        A CVRF document object or objects in XML format
    
    .EXAMPLE
        Get-MsrcCvrfXMLDocument -ID 2016-Nov | Get-MsrcCvrfAffectedSoftware
   
        Get product details from a CVRF document using the pipeline.
   
    .EXAMPLE

        Get-MsrcCvrfAffectedSoftware -cvrfDocument (Get-MsrcCvrfXMLDocument -ID 2016-Nov)

        Get product details from a CVRF document using a variable and parameters
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory,ValueFromPipeline)]
    $cvrfDocument
)
Begin {}
Process {
    $cvrfDocument | 
    ForEach-Object {

        Write-Verbose -Message "Dealing with document:'$($_.cvrfdoc.DocumentTitle)'"
        $doc = $_.cvrfdoc
        $doc.Vulnerability |
        ForEach-Object {

            $v = $_

            $v.ProductStatuses.Status.ProductID | 
            ForEach-Object {
                $id = $_
                Write-Verbose -Message "Dealing with product ID:'$($id)'"
                [PSCustomObject] @{
                    ProductID = $id
                    FullProductName = $(
                        (
                            $doc.ProductTree.FullProductName  | 
                            Where-Object { $_.ProductID -eq $id}
                        ).'#text'
                    )
                    KBArticle = $(
                        $v.Remediations.Remediation | 
                            Where-Object {$_.ProductID -eq $id} |
                            Where-Object {$_.Type -eq 'Vendor Fix'} | # Type = 2
                            ForEach-Object {
                                [PSCustomObject]@{
                                    ID = $_.Description;
                                    URL= $_.URL;
                                    SubType = $_.SubType
                                }
                            }
                    )
                    CVE = $v.CVE
                    Severity = $(
                        (
                            $v.Threats.Threat | 
                            Where-Object {$_.Type -eq 'Severity' } | # type 3
                            Where-Object { $_.ProductID -eq $id }
                        ).Description
                    )
                    Impact = $(
                        (
                            $v.Threats.Threat | 
                            Where-Object {$_.Type -eq 'Impact' } | # type = 0
                            Where-Object { $_.ProductID -eq $id }
                        ).Description
                    )
                    RestartRequired = $(
                        (
                            $v.Remediations.Remediation | 
                            Where-Object { $_.ProductID -eq $id }
                        ).RestartRequired 
                        # | ForEach-Object {
                        #     "$($_)"
                        # }
                    )
                    Supercedence = $(
                        (
                            $v.Remediations.Remediation | 
                            Where-Object { $_.ProductID -eq $id }
                        ).Supercedence 
                        # | ForEach-Object {
                        #     "$($_)"
                        # }
                    )
                    CvssScoreSet = $( 
                        [PSCustomObject] @{ 
                            base=    ($v.CVSSScoreSets.ScoreSet | Where-Object { $_.ProductID -eq $id } ).BaseScore
                            temporal=($v.CVSSScoreSets.ScoreSet | Where-Object { $_.ProductID -eq $id } ).TemporalScore
                            vector=  ($v.CVSSScoreSets.ScoreSet | Where-Object { $_.ProductID -eq $id } ).Vector
                        }
                    )
                }
            }
        }
    }
}
End {}
}