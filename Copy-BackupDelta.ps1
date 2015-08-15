<#
.SYNOPSIS
  Function to copy NEW files to a backup. Existing files will be ignored, either changed or unchanged. Only files 
  that do NOT exist in the destination will be copied.
  Useful for data that is written once but rarely to never changed (eg. collection of mp3 files) to speed up the backup process
.DESCRIPTION
   Did I already mention, that only files that do NOT exist in the destination will be copied?
.PARAMETER SourceDir
   Specifies which directory is used as source
.PARAMETER DestinationDir
   Specifies which directory is used as destination
.EXAMPLE
   Copy-BackupDelta -SourceDir C:\MP3\ -DestinationDir \\NAS\music\
#>

function Copy-BackupDelta{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$true)]
[String]
[ValidateScript({#Must be an existing directory 
					(Test-Path $_.Fullname) -and ($_.PSISContainer)})]
$SourceDir,
[Parameter(Mandatory=$true)]
[String]
<#[ValidateScript({#Must be an existing directory 
					(Test-Path $_.Fullname) -and ($_.PSISContainer)})]#>
$DestinationDir
)	
	if (-not($DestinationDir.endsWith("\"))){
		$DestinationDir = $DestinationDir+"\"
	}if (-not($SourceDir.endsWith("\"))){
		$SourceDir = $SourceDir+"\"
	}
	Get-ChildItem $SourceDir -Recurse | ForEach-Object {
		$src = $_.FullName
		$dst = $src.Replace($SourceDir,$destinationDir)
		if($_.PSISContainer){
			Write-Host "Entering directory $src"
		}
		if(-not (Test-Path -LiteralPath $dst))
		{
			if($_.PSISContainer)
			{
				Write-Host "Creating directory $dst"
				New-Item -ItemType directory $dst 
			} else {
				Write-Host "Copying $src to $dst"
				Copy-Item $src $dst 
			}
		}
	}
}
