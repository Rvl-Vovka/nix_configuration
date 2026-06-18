#Clear-Host #clear screen from PowerShell 7.6.0-preview.6 and other useless info

#if ((pwd).Path -eq "C:\Windows\System32"){cd /Users/vlryz/downloads} #change default start location but only if opened in default starting location

Set-PSReadLineOption -HistoryNoDuplicates #remove duplicates when scrolling history using up arrow
Set-PSReadLineOption -EditMode Windows #sets edit mode to windows, allowing to use ctrl+c, ctrl+v and ctrl+z

#$env:PYTHONIOENCODING="utf-16" #fixes a lot of python errors when using character available only in utf-16

$PSStyle.FileInfo.Directory = "`e[38;2;50;200;255m" #changes look of directories in ls (Get-ChildItem)

#Add-Type -AssemblyName System.Windows.Forms #add often used libraries
#Add-Type -AssemblyName System.Drawing #add often used libraries

#[System.Windows.Forms.Application]::CurrentCulture = [System.Globalization.CultureInfo]'en-UK' #set default culture to english (for Get-Date and other commands)

function la {Get-ChildItem -LiteralPath . -Force} #add la command than shows all files in the directory

function ll {Get-ChildItem -LiteralPath . -Force -Recurse} #add ll command than shows all files in the directory and subdirectories

function prompt {"[40m$(if( -not $?){" [31m✘[39m"})$(if($(whoami) -eq "root"){"[33m ⚡"}) $(whoami)@$(hostname) [30m[44m $($PWD.path.replace($HOME, "~")) [34m[49m[0m "} #formats prompt similar to zsh agnoster theme

function cdl {Set-Location -Path '~/Important/Legendary'} #adds cdl command that sets location to often used one

function cdd {Set-Location -Path '~/Downloads'} #adds cdd command that sets location to often used one

function cdn {Set-Location -Path '/etc/nixos/'} #adds cdn command that sets location to often used one

#function cds {Set-Location -Path 'C:\Windows\System32'} #adds cds command that sets location to often used one

Remove-Alias -Name History

function History {cat (Get-PSReadlineOption).HistorySavePath}

Function Rand { #adds rand command that generates a random string with set length
param(
    [Parameter(Position=0)] 
    [int]$count=20
)
-join(48..57+65..90+97..122|ForEach-Object{[char]$_}|Get-Random -C $count)
}

Function IP { #get public ip
 (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

#function link($target) #get link's location
#{
#    $sh = new-object -com wscript.shell
#    $fullpath = resolve-path $target
#    $targetpath = $sh.CreateShortcut($fullpath).TargetPath
#    #if (Test-Path $targetpath -PathType Container){
#    #Write-Host $targetpath
#    #Write-Host "Set location as this path?"
#    #$y = ([System.Console]::ReadKey($true)).KeyChar.ToString().ToLower()
#    #if ($y -eq "y"){
#    #Set-Location $targetpath
#    #}
#    #}
#    #if ($y -ne "y"){
#    return $targetpath
#    #}
#}

function size{
    Get-ChildItem -Force -Directory | ForEach-Object {
        try{
        $size = (Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{Directory=$_.Name;SizeKB=[math]::Round($size/1KB,2);SizeMB=[math]::Round($size / 1MB, 2);SizeGB=[math]::Round($size / 1GB, 2)}
	}
        catch{}
    } | Where-Object {$_.SizeGB -ne 0} | Sort-Object SizeMB -Descending | Format-Table
}

Remove-Alias -Name copy
function copy {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$arguments
    )
    process {
        # Logic to handle each piped object
        "$arguments" | wl-copy
    }
}
function paste {wl-paste --output --clipboard}
New-Alias -Name rebuild -Value "~/rebuild.sh"
New-Alias -Name n -Value "nvidia-offload"
New-Alias -Name vim -Value "nvim"
function no {(curl -s https://naas.isalman.dev/no | ConvertFrom-Json).reason}
function trid {python ~/.trid/trid.py $args}
function parrot {python ~/.parrot.py}
function rr {python ~/.rr.py}
New-Alias -Name ls -Value "Get-ChildItem"
New-Alias -Name cat -Value "Get-Content"

#New-Alias -Name rar 'C:\Program Files\WinRar\Rar.exe'

#New-Alias -Name TrIDalias 'C:\Program Files\TrID\trid.exe'

#function TrID { TrIDalias $args -d "C:\Program Files\TrID\triddefs.trd"}

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Alias -Name z
Remove-Alias -Name cd
New-Alias -Name cd -Value __zoxide_z -Option AllScope -Scope Global -Force
