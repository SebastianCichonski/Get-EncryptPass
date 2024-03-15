<#
.SYNOPSIS
    Skrypt do zaszyfrowywania hase³ u¿ywanych w skryptach.

.DESCRIPTION
    Skrypt pobiera has³o w formie jawnej i zwraca zaszyfrowany ci¹ znaków. Do szyfrowania u¿ywane jest Windows Data Protection API. 
    Oznacza to, ¿e poœwiadczenia zaszyfrowane w ten sposób s¹ mo¿liwe do odczytania tylko przez dany komputer oraz u¿ytkownika, który wykona³ to polecenie. 
    Niestety skryptu z tak zaszyfrowanym has³em nie u¿yjemy na innych komputerach. Aby to umo¿liwiæ musimy dodatkowo wygenerowaæ klucz u¿ywaj¹c parametru -WithKey
    w takim przypadku skrypt wygeneruje plik z has³em (C:\Temp\Secure\Password.txt) i plik z kluczem (C:\Temp\Secure\Secure.key), które mo¿na wyko¿ystaæ w cmdlecie ConvertFrom-SecureString. 

.PARAMETER LocalUser
    Nazwa u¿ytkownika. Parametr wymagany.

.PARAMETER LocalGroup
    Nazwa grupy. Parametr wymagany.

.INPUTS
    None

.OUTPUTS
    Plik C:\Temp\Secure\Password.txt.
    Plik C:\Temp\Secure\Secure.key.

.NOTES
    Version:        1.1
    Author:         Sebastian Cichonski
    Creation Date:  1.2024
    Projecturi:     https://gitlab.com/powershell1990849/new-srusersshare
  
.EXAMPLE
    Get-SREncryptPass.ps1 -Phrase tajnehasl0

    Encrypted Password: 
    01000000d08c9ddf0115d1118c7a00c04fc297eb01000000625d34456177704697ebf56209759b940000000002000000000003660000c0000000100000003e27cbf9439f69e23e
    4ab5606168d2040000000004800000a000000010000000c2935be984afdbf8bfd2a1ea0e28696b180000006991ad8ce5c13d977bd5dcb775196ac973405afe5bee21de14000000
    d70a48082e92cd0d4ce4bfa4fc708750c4e51358        

.EXAMPLE
   Get-SREncryptPass.ps1 -Phrase tajnehasl0 -WithKey

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory, Position=1)]
    [String] $Phrase,

    [switch] $WithKey
)

$KeyFile = "C:\Temp\Secure\Secure.key"
$PasswordFile = "C:\Temp\Secure\Password.txt"
$SecureKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($SecureKey)

if($WithKey -eq $false) {
    $Secure = ConvertTo-SecureString -String "$Phrase" -AsPlainText -Force
    $Encrypt = ConvertFrom-SecureString -SecureString $Secure
    Write-Host "Encrypted Password: " 
    Write-Host -ForegroundColor DarkCyan "$Encrypt"
}
else {
    $Path = Split-Path -Path $KeyFile -Parent
    New-Item -Path $Path -Force -ItemType Directory | Out-Null
    $SecureKey | Out-File  $KeyFile -Force
    $SecureKey = Get-Content -Path $KeyFile
    $Secure = ConvertTo-SecureString -String "$Phrase" -AsPlainText -Force 
    $Encrypt = ConvertFrom-SecureString -SecureString $Secure -Key $SecureKey
    $Encrypt | Out-File  $PasswordFile -Force
}


