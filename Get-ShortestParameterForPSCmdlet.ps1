function Get-ShortestParameterForPSCmdlet{
    <#
    .SYNOPSIS
    Returns a list of parameters and the shortest parameter string that can be used with the passed in cmdlet. 
    
    .DESCRIPTION
    Used for determining the shortest powershell parameter strings that can be used with a cmdlet. 
    E.g. Invoke-restmethod downloading a file using -outfile.  The parameter could be any of: -O, -Ou, -Out, -Outf, -outfi, -outfil, -outfile

    
    .PARAMETER cmdletName
    Parameter description
    
    .PARAMETER detailed
    Parameter description
    
    .EXAMPLE
    Get-ShortestParameterForPSCmdlet -cmdletName "Invoke-WebRequest"

    Known aliases for iwr include:
    Invoke-WebRequest

    name                            shortest
    ----                            --------
    AllowUnencryptedAuthentication  Al
    Authentication                  Au
    Body                            B
    Certificate                     Certificate
    CertificateThumbprint           CertificateT
    ContentType                     Co
    Credential                      Cr
    CustomMethod                    CM, Cu
    DisableKeepAlive                D
    Form                            F
    Headers                         H
    InFile                          I
    MaximumRedirection              MaximumRed
    MaximumRetryCount               MaximumRet
    Method                          Me
    NoProxy                         N
    OutFile                         O
    PassThru                        Pa
    
    .NOTES
    

    .Author
    Kyle Snihur

    .Date 
    2022-03-05
    #>
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$cmdletName,
        [switch]$detailed
    )

    $cmdletAliases = Get-Alias -Definition $cmdletName -ErrorAction SilentlyContinue| Select-Object Name
    if(([string]::IsNullOrEmpty($cmdletAliases)) -eq $false){
        Write-host "Known aliases for $cmdletname include:`n$($cmdletAliases.Name)" -ForegroundColor Green
    }
    else{
        $cmdletAliases = Get-Command -CommandType Alias -Name $cmdletName   -ErrorAction SilentlyContinue      
        if(([string]::IsNullOrEmpty($cmdletAliases)) -eq $false){
            Write-host "Known aliases for $cmdletname include:`n$($cmdletAliases.ResolvedCommandName)" -ForegroundColor Green
        }
        else{
            Write-host "No Known aliases for $cmdletname" -ForegroundColor Green
        }
    }

    $aliases = (Get-Command $cmdletName -ErrorAction sile ).Parameters.Values | Select-Object name, aliases
    if(([string]::IsNullOrEmpty($aliases)) -eq $false){
        $info = ( get-help $cmdletName -Full).parameters.parameter | Select-Object name, @{n="knownAliases";e={$name = $_.name; ($aliases | Where-Object {    $_.Name -eq $name}  | Select-Object Aliases).aliases}},@{L='TempShortest';E={  $_.Name }},@{n="shortestParameter";e={}}

        foreach ($parameter in $info) {
            for ($j=1; $j -lt $parameter.tempShortest.Length; $j++) {
                $a = $parameter.Name.Substring(0,$j)
                if (($info.Name -like "$a*").Count -eq 1) {
                    $parameter.tempShortest = $a
                }
            }
        }
        $info | ForEach-Object {
            if(([string]::IsNullOrEmpty($_.knownAliases)) -eq $false ){
                $tempstring = ""
                if($_.knownAliases.count -gt 1){   
                    for ($i = 0; $i -lt $_.knownAliases.Count; $i++) {
                        if($i -eq $_.knownAliases.count){
                            $tempstring += $_.knownAliases
                        }
                        else { $tempstring += ", $($_.knownAliases)"}
                    }
                }
                else { $tempstring += $_.knownAliases}
                
                if( $null -eq $tempstring -or $tempstring -eq ""){ $tempstring += $_.tempShortest }
                else{ $tempstring += ", $($_.tempShortest)" }
                $_.shortestParameter = $tempstring
            }
            else{  $_.shortestParameter = $_.tempShortest }
        } 
        if($detailed){
            $info
        }
        else { $info | Select-Object name, shortestParameter    }   
    }
    else{
        Write-Host "NO cmdlet named $cmdletname found"
    } 
}