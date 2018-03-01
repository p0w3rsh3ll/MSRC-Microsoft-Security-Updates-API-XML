Microsoft Security Response Center (MSRC) security updates
==========================================================

The Microsoft Security Response Center (MSRC) portal is located at https://portal.msrc.microsoft.com/en-us/security-guidance

<a name="Intent"/>

## Intent

This repository is currently a working copy of another implementation of the MSRC-Microsoft-Security-Updates-API repository.

    * core format
        The original one works mainly with Json.
        This one works mainly with XML.
        Why? Since Windows PowerShell version 1.0, XML is a first class citizen.
        But Json isn't and has been introduced in Windows PowerShell 3.0.

    * parameters
        Have less parameters to pass and use only once the full CVRF document

    * performance
        Get more speed? Really?

    * html rendering
        Write another html conversion mechanism leveraging built-in cmdlet such as ConvertTo-Htlm

    * cross-platform compatibility
        Was the previous implementation compatible with PowerShell Core 6.x?
        Anyway, make sure this one is compatible.

    * misc :+1: :clap:
        Showcase some functions to get data from the portal without using an API key.


