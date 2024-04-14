#Check if HyperV is installed

#--------- supposedly it can enable virtulization on your system ----------
#enable-windowsoptionalfeature -online -featurename HypervisorPlatform -all


[string]$featureAvailable= Read-Host "Is Hyper-V Features Installed On Your Machine? (yes/no)"

while("yes","no","y","n" -notcontains $featureAvailable){
    $featureAvailable = Read-Host "Will this VM use dyanmic memory? (yes/no)"
}
if($featureAvailable -eq "no" -or $featureAvailable -eq "n" ){
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -Source "SourcePath"
    Write-Output "You Must Restart Your System for the Features to be Applied and Come Back to Continue"
}
else{
    #mate ain't gonna do nothing
}

#----------------Questions For User-------------------
[string]$vmName= Read-Host ”Name of Virtual Machine”
#__________________________________________________________

#Specify Generation Type for VM
Write-Output "
----------
Generation 1 
This virtual machine generation supports 32-bit and 64-bit guest operating systems and provides
virtual hardware which has been available in all previous versions of Hyper-V.
Generation 2
This virtual machine generation provides support for newer virtualization features, has UEFI-based
firmware, and requires a supported 64-bit guest operating system.
----------"

[int32]$generation = Read-Host "Generation Type"
#__________________________________________________________
[string]$dynamic = $null
Write-Output "Dynamic Memory is a feature that balances virtual machine physical memory automatically in Hyper-V environments. 
	It is intended to reclaim unused memory from the low-load VMs and reassign it to other VMs required.
    For Dynamic Memory Minimum and Maximum Memory have to be applied"
while("yes","no" -notcontains $dynamic){
    $dynamic = Read-Host "Will this VM use dyanmic memory? (yes/no)"
}
if($dynamic -eq "yes"){
    [bool]$dynMemory = $true
    [int64]$minMemory = Read-Host "Memory Minimum (MB)"
    [int64]$maxMemory = Read-Host "Memory Maximum (MB)"
    [int64]$startMemory = Read-Host "Starting Memory (MB)"
    #convert to bytes
    $minMemory = 1MB*$minMemory
    $maxMemory = 1MB*$maxMemory
    $startMemory = 1MB*$startMemory
    [int64]$memory = $minMemory
}
else{
    [int64]$memory = Read-Host "Memory (MB)"
    #convert to bytes
    $memory = 1MB*$memory
}

#__________________________________________________________
[string]$makeSwitch= Read-host "You need to Assign your VM into a Switch.
Do you want to make a new switch? (yes/no)"
if($makeSwitch -eq "yes"){
    [int32]$switchType= Read-Host "Please choose what kind of switch you want to make.
    1.External Virtual Switch with Existing Network Adapter.
    2.Create an Internal or Private Switch."
    
    if($switchType -eq "1" ){
    #If you want an external virtual switch with existing network adapters
        Write-Output "Your NET Adapters"
            Get-NetAdapter
                [string]$netAdapter= Read-Host "Name of your preferable adapter"
                [string]$switchName = Read-Host ”Name of Virtual Switch"
                    New-VMSwitch -Name $switchName -NetAdapterName $netAdapter
    }
    else{
        ##Internal or private$switchName
        [string]$internalPrivate= Read-Host "Specify if you want Internal or Private Switch"
        New-VMSwitch -Name $switchName -SwitchType $internalPrivate
    }

}
    else {
        Write-Host "--------AVAILABLE SWITCHES--------" -BackgroundColor Black
        Get-VMSwitch | Select-Object -ExpandProperty Name
        [string]$vmSwitch = Read-Host "Please enter a virtual switch name"
    }
#Write-Host "--------AVAILABLE SWITCHES--------" -BackgroundColor Black
#Get-VMSwitch | Select-Object -ExpandProperty Name
#Write-Host "--------AVAILABLE SWITCHES--------" -BackgroundColor Black
[string]$vmSwitch = Read-Host "Please enter a virtual switch name"
#__________________________________________________________
[int32]$cpu = Read-Host "Number of CPUs"
#__________________________________________________________
[string]$vmPath = Read-Host "Enter path for VM config files (Ex E:\VM\)"
[string]$newVMPath = $vmPath
#__________________________________________________________
[string]$vhdPath = Read-Host "Enter path where .vhdx will reside (Ex E:\VHD\)"
[string]$newVHD = $vhdPath+$VMName+".vhdx"
[int64]$vhdSize = Read-Host "Enter VHDSize (GB)"
$vhdSize = [math]::round($vhdSize *1Gb, 3) #converts GB to bytes
#__________________________________________________________
 
#----------------END USER CREATION QUESTIONS---------------
 
try{
    #-----------------CONFIRM CREATE NEW VM----------------
    Write-Host "Creating new VM:" $vmName "Generation type:" $generation `
        "Starting memory:" $memory "stored at:" $newVMPath ", `
            with its .vhdx stored at:" $newVHD "(size" $vhdSize ")" -ForegroundColor Cyan
    [string]$confirm = $null
    while("yes","no" -notcontains $confirm){
        $confirm = Read-Host "Proceed? (yes/no)"
    }
    #---------------END CONFIRM CREATE NEW VM--------------
     
    if($confirm -eq "yes"){
         #------------------CREATE NEW VM-----------------------
        NEW-VM –Name $vmName -Generation $generation –MemoryStartupBytes $memory `
            -Path $newVMPath –NewVHDPath $newVHD –NewVHDSizeBytes $vhdSize | Out-Null
        Start-Sleep 5 #pause script for a few seconds to allow VM creation to complete
        #----------------END CREATE NEW VM---------------------
 
        #---------------CONFIGURE NEW VM-----------------------
        ADD-VMNetworkAdapter –VMName $vmName –Switchname $vmSwitch
        #______________________________________________________
        Set-VMProcessor –VMName $vmName –count $cpu
        #______________________________________________________
        if($dynMemory -eq $true){
            Set-VMMemory $vmName -DynamicMemoryEnabled $true -MinimumBytes $minMemory `
                -StartupBytes $startMemory -MaximumBytes $maxMemory
        }
        Start-Sleep 8 #pause script for a few seconds - allow VM config to complete
        #---------------END CONFIGURE NEW VM-------------------
        #display new VM information
        Get-VM -Name $vmName | Select-Object Name,State,Generation,ProcessorCount,`
            @{Label=”MemoryStartup”;Expression={($_.MemoryStartup/1MB)}},`
            @{Label="MemoryMinimum";Expression={($_.MemoryMinimum/1MB)}},`
            @{Label="MemoryMaximum";Expression={($_.MemoryMaximum/1MB)}} `
            ,Path,Status | Format-Table -AutoSize
    }
    else{
        Exit
    }
    
}
catch{
    Write-Host "An error was encountered creating the new VM" `
        -ForegroundColor Red -BackgroundColor Black
    Write-Error $_
}