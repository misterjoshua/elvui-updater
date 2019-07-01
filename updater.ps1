param (
    [Parameter(Mandatory = $true)]
    [string] $InstallPath
)

enum DownloadUrlMethod {
    ClientApi = 0
    PageScrape = 1
}

function Get-LatestDownloadUrl([DownloadUrlMethod] $method = [DownloadUrlMethod]::ClientApi) {
    switch ($method) {
        "ClientApi" { $href = Get-LatestDownloadUrlFromApi; continue }
        "PageScrape" { $href = Get-LatestDownloadUrlFromPage; continue }
        Default { throw "Unsupported method: $method" }
    }

    Write-Host @infoStyle "The download href is $href"
    $href
}

# Get the latest download url from the tukui client api
function Get-LatestDownloadUrlFromApi {
    ((Invoke-WebRequest $clientApiUrl).Content | ConvertFrom-Json).url
}

# Get the latest download url by scraping the download page
function Get-LatestDownloadUrlFromPage {
    $request = Invoke-WebRequest $updatePage
    $downloadLink = $request.Links | Where-Object { $_.href -like "*elvui*.zip" } | Select -First 1
    $downloadBaseUrl + $downloadLink.href
}

function Get-ZipLocalPath($DownloadUrl) {
    $fileName = $DownloadUrl -replace ".*/",""
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

    $DownloadUrl = Get-LatestDownloadUrl
    $zipPath = Get-ZipLocalPath -DownloadUrl $DownloadUrl

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
