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
	$DestinationDir,
	[Switch]
	$VerifyHash
	)	
	
	if (-not($DestinationDir.endsWith("\"))){
		$DestinationDir = $DestinationDir+"\"
	}if (-not($SourceDir.endsWith("\"))){
		$SourceDir = $SourceDir+"\"
	}
	Get-ChildItem $SourceDir -Recurse -Force | ForEach-Object {
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
				$count=0
				$hashOK=$false
				while(-not $hashOK){
					Write-Host ("Copying $src to $dst ({0:N2} MB)" -f ($_.Length/1MB))
					Copy-Item $src $dst 
					if ($VerifyHash){
						$hashSrc = Get-FileHash -Path $src -Algorithm SHA256
						$hashDst = Get-FileHash -Path $dst -Algorithm SHA256
						if ($hashSrc.Hash -eq $hashDst.Hash){
							$hashOK = $true
							#Write-Host ("File Hashes match SRC={0} DST={1}" -f $hashSrc.Hash,$hashDst.Hash)
						}else{
							Write-Error ("File Hashes do not match! SRC={0} DST={1}" -f $hashSrc.Hash,$hashDst.Hash)
							$count = $count+1
							if($count -gt 10){
								throw ("File Hashes do not match! SRC={0} DST={1}" -f $hashSrc.Hash,$hashDst.Hash)
							}
						}
					}else{
						$hashOK = $true
					}
				}
			}
		}
	}
}
