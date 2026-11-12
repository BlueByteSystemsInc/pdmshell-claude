Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-PDMShellMcp {
    if ($env:OS -ne 'Windows_NT') { throw 'PDMShell requires native Windows and the SOLIDWORKS PDM client. WSL is not supported.' }
    $candidate = if ($env:PDMSHELL_MCP_PATH) { $env:PDMSHELL_MCP_PATH } else {
        Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Blue Byte Systems\PDMShell\current\MCP\pdmcli.mcp.exe'
    }
    if (-not [IO.Path]::IsPathRooted($candidate)) { throw 'PDMSHELL_MCP_PATH must be an absolute path.' }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { return $null }
    return [IO.Path]::GetFullPath($candidate)
}

function Assert-PDMShellSignature([string]$Path) {
    $signature = Get-AuthenticodeSignature -LiteralPath $Path
    if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate -or
        $signature.SignerCertificate.Subject -notmatch '(^|,\s*)O=BLUE BYTE SYSTEMS INC(,|$)') {
        throw 'The file does not have a valid Blue Byte Systems signature. Installation was stopped.'
    }
}

function Start-PDMShellInstaller([string]$Path) {
    Assert-PDMShellSignature $Path
    # Keep the official installer interactive, including its license and vault setup choices.
    $process = Start-Process -FilePath $Path -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "PDMShell installation did not complete (exit $($process.ExitCode))." }
}
