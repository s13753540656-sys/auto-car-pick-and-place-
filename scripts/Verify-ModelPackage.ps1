param([Parameter(Mandatory=$true)][string]$ArchivePath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-StreamDigest([IO.Stream]$Stream) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($Stream)).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

$resolvedPath = (Resolve-Path -LiteralPath $ArchivePath).Path
$externalPath = $resolvedPath + '.sha256'
if (Test-Path -LiteralPath $externalPath) {
    $expected = ([IO.File]::ReadAllText($externalPath).Trim() -split '\s+',2)[0].ToLowerInvariant()
    if ($expected -notmatch '^[a-f0-9]{64}$') { throw 'Invalid external SHA-256 file' }
    $stream = [IO.File]::OpenRead($resolvedPath)
    try { $actual = Get-StreamDigest $stream } finally { $stream.Dispose() }
    if ($actual -ne $expected) { throw 'Archive SHA-256 mismatch' }
    Write-Output 'Archive SHA-256 matched.'
} else { Write-Output 'No adjacent .sha256 file; checking internal model manifest only.' }

$archive = [IO.Compression.ZipFile]::OpenRead($resolvedPath)
try {
    $entryNames = @{}
    foreach ($entry in $archive.Entries) {
        if ($entry.FullName -match '(^|/)\.\.(/|$)|^/|^[A-Za-z]:|\\') { throw 'Unsafe archive path' }
        if ($entryNames.ContainsKey($entry.FullName)) { throw 'Duplicate archive entry' }
        $entryNames[$entry.FullName] = $true
    }
    $manifest = $archive.GetEntry('SHA256SUMS.txt')
    if (-not $manifest) { throw 'Missing internal SHA256SUMS.txt' }
    $reader = [IO.StreamReader]::new($manifest.Open(),[Text.Encoding]::UTF8)
    try { $lines = $reader.ReadToEnd() -split '\r?\n' } finally { $reader.Dispose() }
    $listed = @{}
    foreach ($line in $lines) {
        if (-not $line.Trim()) { continue }
        if ($line -notmatch '^([a-fA-F0-9]{64})  (.+)$') { throw 'Invalid manifest line' }
        $digest = $Matches[1].ToLowerInvariant()
        $name = $Matches[2]
        if ($name -notmatch '\.(sldprt|sldasm|step)$') { throw 'Manifest contains unsupported file type' }
        if ($listed.ContainsKey($name)) { throw 'Duplicate manifest model' }
        $listed[$name] = $true
        $entry = $archive.GetEntry($name)
        if (-not $entry) { throw "Missing model: $name" }
        $stream = $entry.Open()
        try { $actual = Get-StreamDigest $stream } finally { $stream.Dispose() }
        if ($actual -ne $digest) { throw "Model SHA-256 mismatch: $name" }
    }
    if ($listed.Count -eq 0) { throw 'Manifest has no models' }
    $readmeCount = 0
    foreach ($entry in $archive.Entries) {
        if (-not $entry.Name -or $listed.ContainsKey($entry.FullName) -or $entry.FullName -eq 'SHA256SUMS.txt') { continue }
        if ($entry.FullName -notmatch '^[^/]+\.txt$') { throw "Unlisted file: $($entry.FullName)" }
        $readmeCount++
    }
    if ($readmeCount -ne 1) { throw 'Expected one top-level text instruction file' }
    Write-Output "Verification passed: $($listed.Count) model files, all hashes matched."
    Write-Output 'This checks bytes only; SolidWorks references, mates and compatibility are not validated.'
} finally { $archive.Dispose() }
