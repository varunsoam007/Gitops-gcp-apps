param(
    [string]$Registry = "oci://registry-1.docker.io/varunsoam"
)

$chartDir = Join-Path $PSScriptRoot "charts\global-templates"
Write-Host "Packaging global-templates from $chartDir..." -ForegroundColor Cyan

$packageOutput = helm package $chartDir
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to package chart"
    exit 1
}

$chartArchive = ($packageOutput -split "to: ")[-1].Trim()
Write-Host "Packaged chart: $chartArchive" -ForegroundColor Green

Write-Host "Pushing to $Registry..." -ForegroundColor Cyan
helm push $chartArchive $Registry

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully pushed $chartArchive to $Registry!" -ForegroundColor Green
} else {
    Write-Warning "Push failed. Make sure you are authenticated: 'helm registry login registry-1.docker.io -u <username>'"
}
