Import-Properties -Package Pask

Set-Property ReleaseAssetPattern -Default ""

# Synopsis: Create a new release on GitHub
Task New-GitHubRelease {
    Set-Property GitHubOwner
    Set-Property GitHubRepo
    Set-Property GitHubToken

    # This will throw an error if git isn't available
	Get-Command git | Out-Null

    $Headers = @{
        Authorization = 'Basic {0}' -f [System.Convert]::ToBase64String([char[]]$GitHubToken)
    }

    $ReleaseName = ('v{0}' -f $Version.SemVer)
    $CommitIsh = Exec { git -C "$PaskFullPath" rev-parse HEAD }
    $ReleaseUri = "https://api.github.com/repos/{0}/{1}/releases" -f $GitHubOwner, $GitHubRepo

    $Body = @{
        tag_name = $ReleaseName;
        target_commitish = $CommitIsh;
        name = $ReleaseName;
        prerelease = (-not [string]::IsNullOrEmpty($Version.PreReleaseLabel))
    } | ConvertTo-Json

    "Creating release {0}" -f $ReleaseName
    $Release = Invoke-RestMethod -Headers $Headers -Uri $ReleaseUri -Method Post -Body $Body -ErrorAction Stop
    " - created release {0}" -f $Release.html_url

    if ((Test-Path $BuildOutputFullPath) -and $ReleaseAssetPattern) {
        Get-ChildItem -Path $BuildOutputFullPath -File | Where { $_.Name -match $ReleaseAssetPattern } | ForEach {
            $UploadUri = '{0}?name={1}' -f ($Release.upload_url -split '{')[0], $_.Name
            "Uploading release asset {0}" -f $_.Name
            $Asset = Invoke-RestMethod -Headers $Headers -Uri $UploadUri -Method Post -ContentType "application/zip" -InFile $_.FullName -ErrorAction Stop
            " - uploaded asset {0}" -f $Asset.browser_download_url
        }
    }
}