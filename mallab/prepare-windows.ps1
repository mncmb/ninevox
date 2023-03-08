param ( [String] $ipgate , [String] $iface)


# https://stackoverflow.com/questions/46830703/downloading-large-files-in-windows-command-prompt-powershell
function my-downloadFile($url, $targetFile)
{
    "Downloading $url"
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    $buffer = new-object byte[] 256KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0)
    {
        #[System.Console]::CursorLeft = 0
        #[System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }
    "Finished Download"
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}


cd ~
cd Downloads
# https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3
$repo = "mentebinaria/retoolkit"
$releases = "https://api.github.com/repos/$repo/releases"
$dlurl = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].assets.browser_download_url

$outfile = ($dlurl -split "/")[-1]

Write-host "Downloading 1GB of RE tools, this might take a while... "
my-downloadFile $dlurl "$env:USERPROFILE\Desktop\$outfile"



# set networking 
Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
new-netroute -interfacealias $iface -NextHop $ipgate -destinationprefix 0.0.0.0/0 -confirm:$false
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses $ipgate
sleep 10 # magic sleep 

Write-host "setup done, netadapter can be disabled now"
Disable-NetAdapter -Name "Ethernet" -Confirm:$false