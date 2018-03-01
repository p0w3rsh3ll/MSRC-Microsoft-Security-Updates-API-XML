Function Get-MsrcCvrfXMLDocument {
<#
    .SYNOPSIS
        Get a MSRC CVRF document in XML format

    .DESCRIPTION
       Calls the MSRC CVRF API to get a CVRF document by ID

    .PARAMETER ID
        Get the CVRF document for the specified CVRF ID (ie. 2016-Aug)


    .EXAMPLE
       Get-MsrcCvrfXMLDocument -ID 2016-Aug

       Get the Cvrf document '2016-Aug'

    .NOTES
        An API Key for the MSRC CVRF API is required
        To get an API key, please visit https://portal.msrc.microsoft.com

#>   
[CmdletBinding()]     
Param (
)
DynamicParam {

    if (-not ($global:MSRCApiKey)) {

	    Write-Warning -Message 'You need to use Set-MSRCApiKey first to set your API Key'

    } else {  
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $ParameterName = 'ID'
        $AttribColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $Param1Att = New-Object System.Management.Automation.ParameterAttribute
        $Param1Att.Mandatory = $true        
        $AttribColl1.Add($Param1Att)

        try {
            $allCVRFID = Get-CVRFID
        } catch {
            Throw 'Unable to get online the list of CVRF ID'
        }
        if ($allCVRFID) {
            $AttribColl1.Add((New-Object System.Management.Automation.ValidateSetAttribute($allCVRFID)))
            $Dictionary.Add($ParameterName,(New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttribColl1)))
        
            $Dictionary
        }
    }
}
Begin {}
Process {

    # Common
    $RestMethod = @{
        uri = '{0}/cvrf/{1}?{2}' -f $msrcApiUrl,$PSBoundParameters['ID'],$msrcApiVersion
        ErrorAction = 'Stop'
    }
    
    # Add proxy and creds if required
    if ($global:msrcProxy) {
        
        $RestMethod.Add('Proxy', $global:msrcProxy)
    
    }
    if ($global:msrcProxyCredential) {
        
        $RestMethod.Add('ProxyCredential',$global:msrcProxyCredential)
    
    }

    # Adjust header based on our variables
    if ($global:MSRCApiKey) {
        
        $RestMethod.Add('Header',@{ 'Api-Key' = $global:MSRCApiKey })
    
      } else {
        
        Write-Warning -Message 'You need to use Set-MSRCApiKey first to set your API Key'        
    
    }

    # If we have a header defined, we proceed
    if ($RestMethod['Header']) {
        
        $RestMethod.Header.Add('Accept','application/xml')

        try {
    
            Write-Verbose -Message "Calling $($RestMethod.uri)"

            Invoke-RestMethod @RestMethod
     
        } catch {
            Write-Error "HTTP Get failed with status code $($_.Exception.Response.StatusCode): $($_.Exception.Response.StatusDescription)"       
        }
    
    }
}
End {}
}