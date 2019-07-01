param (
    [Parameter(Mandatory = $true)]
    [string] $InstallPath
)

function Get-LatestDownloadHref {
    $request = Invoke-WebRequest $updatePage
    $downloadLink = $request.Links | Where-Object { $_.href -like "*elvui*.zip" } | Select -First 1
    $href = $downloadBaseUrl + $downloadLink.href

    Write-Host @infoStyle "The download href is $href"
    $href
}

function Get-ZipLocalPath($downloadHref) {
    $fileName = $downloadHref -replace ".*/",""
    Write-Host @infoStyle "The newest file is $fileName"
    $env:TEMP + "\$fileName"
}

###############################################################################
# Script begins
###############################################################################

$ErrorActionPreference = "Stop"

$downloadBaseUrl = "https://www.tukui.org"
$updatePage = "https://www.tukui.org/download.php?ui=elvui"
$infoStyle = @{Foreground = "Cyan"}

try {
    Write-Host @infoStyle "Checking for elvui updates"

    $downloadHref = Get-LatestDownloadHref
    $zipPath = Get-ZipLocalPath -downloadHref $downloadHref

    if (-not (Test-Path $zipPath)) {
        Write-Host @infoStyle "Downloading $downloadUrl to $zipPath"
        Invoke-WebRequest $downloadUrl -OutFile $zipPath

        Write-Host @infoStyle "Extracting to $installPath"
        Expand-Archive -Path $zipPath -DestinationPath $installPath -Force
    } else {
        Write-Host @infoStyle "Already up to date."
        Start-Sleep 2
    }
} catch {
    Write-Error $_
}
