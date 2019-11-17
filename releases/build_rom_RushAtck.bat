@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s" %*&goto:eof
#==============================================================
$zip0="gberet.zip"
$zip1="rushatck.zip"

$ifiles=`
    "577h03.10c","577h02.8c","577h01.7c","577h01.7c",`
    "577l06.5e","577h05.4e","577l08.4f","577l04.3e",`
    "577h07.3f",`
    "577h10.5f","577h11.6f","577h09.2f"

$ofile="a.rushatck.rom"
$ofileMd5sumValid="77c3e9fb3763204f8e118a7442991c6e"

if (!((Test-Path "./$zip0") -And (Test-Path "./$zip1"))) {
    echo "Error: Cannot find zip files."
	echo ""
	echo "Put $zip0 and $zip1 into the same directory."
}
else {
    Expand-Archive -Path "./$zip0" -Destination ./tmp/ -Force
    Expand-Archive -Path "./$zip1" -Destination ./tmp/ -Force

    cd tmp
    Get-Content $ifiles -Enc Byte -Read 512 | Set-Content "../$ofile" -Enc Byte
    cd ..
    Remove-Item ./tmp -Recurse -Force

    $ofileMD5sumCurrent=(Get-FileHash -Algorithm md5 "./$ofile").Hash.toLower()
    if ($ofileMD5sumCurrent -ne $ofileMd5sumValid) {
        echo "Expected checksum: $ofileMd5sumValid"
        echo "  Actual checksum: $ofileMd5sumCurrent"
        echo ""
        echo "Error: Generated $ofile is invalid."
        echo ""
        echo "This is more likely due to incorrect $zip0 or $zip1 content."
    }
    else {
        echo "Checksum verification passed."
        echo ""
        echo "Copy $ofile into root of SD card along with the rbf file."
    }
}
echo ""
echo ""
pause

