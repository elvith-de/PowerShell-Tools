<#
.SYNOPSIS
  Helper function to resize (and rename, if some specific characters are used) ALL images in a folder to prepare 
  them before uploading them into a gallery
  
  !!Requires ImageMagick to be installed!!
  
.DESCRIPTION
  ä, ö, ü and ß in the filename will be replaced
  images will be resized to have a width of 1200px
  
.PARAMETER Directory
  Optional, defines with directory to work on (default ist the current directory)
.EXAMPLE
  Format-ImagesGallery -Directory "C:\Pictures\for Upload\"
#>

function Format-ImagesForGallery {
    [CmdletBinding()]
    param(
        $directory = (Get-Item .)
    )
    
    # Insert gallery url here; url will be opened in default browser after resize is done
    # remove this line and line #43 if not desired
    $url = "http://example.com"

    $filelist = Get-ChildItem $directory -Exclude Thumbs.db 

    $filelist | ForEach-Object {
        $file = $_
        $path = Split-Path $_ -Parent
        $filename = (Split-Path $_ -Leaf)
        if ($filename.toLower() -like "*ä*" -or $filename.toLower() -like "*ö*" -or $filename.toLower() -like "*ü*" -or $filename.toLower() -like "*ß*") {
            $filename = $filename.Replace("Ä","Ae").Replace("Ö","Oe").Replace("Ü","Ue").Replace("ä","ae").Replace("ö","oe").Replace("ü","ue").Replace("ß","ss")
            Move-Item $_ "$path\$filename"
        }
        
        mogrify -resize 1200 "$path\$filename"
        
    }

    Start "$url"

}
