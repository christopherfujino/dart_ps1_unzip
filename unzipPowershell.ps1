$inputPath = $args[0]

Write-Host "We're going to unzip $inputPath with pure powershell"

Microsoft.PowerShell.Archive\Expand-Archive $inputPath -DestinationPath purePowershellOut
