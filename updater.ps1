param (
    [Parameter(Mandatory = $true)]
    [string] $InstallPath
)

enum DownloadHrefMethod {
    ClientApi = "ClientApi"
    PageScrape = "PageScrape"
}

function Get-LatestDownloadHref([DownloadHrefMethod] $method = [DownloadHrefMethod]::ClientApi) {
    switch ($method) {
        "ClientApi" { $href = Get-LatestDownloadHrefFromApi; continue }
        "PageScrape" { $href = Get-LatestDownloadHrefFromPage; continue }
        Default { throw "Unsupported method: $method" }
    }

    Write-Host @infoStyle "The download href is $href"
    $href
}

# Get the latest download url from the tukui client api
function Get-LatestDownloadHrefFromApi {
    ((Invoke-WebRequest $clientApiUrl).Content | ConvertFrom-Json).url
}

# Get the latest download url by scraping the download page
function Get-LatestDownloadHrefFromPage {
    $request = Invoke-WebRequest $updatePage
    $downloadLink = $request.Links | Where-Object { $_.href -like "*elvui*.zip" } | Select -First 1
    $downloadBaseUrl + $downloadLink.href
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
$clientApiUrl = "https://www.tukui.org/client-api.php?ui=elvui"
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
