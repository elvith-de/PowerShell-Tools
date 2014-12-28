<#
Code-Snippet to download all (published) 31C3 recordings with Windows Powershell
Script will download the talks using BITS. Download will only use free bandwidth
and shouldn't therefore interfere with the stream, etc.
 
Hint: Schedule script in the task scheduler to download newly published talks
 
Prerequisites: Powershell v3.0, uses default proxy, if set
 
Before Executing: change $dst to an existing folder where the talks should be downloaded, optional change $src and $filter when other version than HD is desired
#>
 
$src = "http://cdn.media.ccc.de/congress/2014/h264-hd/"
$dst = 'D:\31C3\'
$filter = "31C3-*_hd.mp4"
$transferName = "31C3 Talks"
 
 
# Collect available talks
$published = (Invoke-WebRequest $src).Links | ? href -like $filter | select href
 
Write-Debug "Available Talks"
$published | %{Write-Debug $_.href}
# Collect all downloaded talks
$local = Get-ChildItem $dst | ? name -like $filter | % {$_.name}
 
 
Write-Debug "Downloaded Talks"
$local | %{Write-Debug $_}
 
# Only talks that haven't finished downloading
$tbd = $published | ? { $local -notcontains $_.href}
 
 
Write-Debug "To Be Downloaded"
$tbd | %{Write-Debug $_.href}
 
# Check if a transfer is running in background
$transfer = Get-BitsTransfer -Name $transferName -ErrorAction SilentlyContinue
 
# build links and local filenames
$links = $tbd | %{"{0}{1}" -f $src,$_.href}
$localfiles = $tbd | %{"{0}{1}" -f $dst,$_.href}
 
Write-Debug "Links"
$links | %{Write-Debug $_}
# if no transfer is running
if ($transfer -eq $null){      
        # Download all teh talkz!
        if(($links -ne $null) -and ($localfiles -ne $null)){
                Start-BitsTransfer -DisplayName $transferName -Source $links -Destination $localfiles -Priority High -Description "Please wait while downloading..."
        }
}
# transfer is running
else
{
        # filter all talks currently being downloaded
        $links = $links | ?{$transfer.FileList.RemoteName -notcontains $_}
        $localfiles = $localfiles | ?{$transfer.FileList.LocalName -notcontains $_}
        # if there are still talks in the list...
        if(($links -ne $null) -and ($localfiles -ne $null)){
                # Add them to the transfer job
                Add-BitsFile -BitsJob $transfer -Source $links -Destination $localfiles
        }
        $transfer | Resume-BitsTransfer
}
