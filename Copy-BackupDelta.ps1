<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

function Copy-BackupDelta{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$true)]
[String]
<#[ValidateScript({#Must be an existing directory 
					(Test-Path $_.Fullname) -and ($_.PSISContainer)})]#>
$SourceDir,
[Parameter(Mandatory=$true)]
[String]
<#[ValidateScript({#Must be an existing directory 
					(Test-Path $_.Fullname) -and ($_.PSISContainer)})]#>
$DestinationDir
)	
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
