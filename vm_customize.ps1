#######################################################################
# WARNING: do not run the script without consent from vm owner
#
# SSH to test-vc     : ssh administrator@test-virtual-cluster-ip
# Start Powercli    : c:\pcli.bat
# Connect to test-vc : c:\connectvc.ps1
# Run this script   : c:\vm_customize.ps1
#######################################################################
# sampe content of the csv file
# vm_name,vm_host,vm_datastore
# vm-worker-001,10.10.10.10,TestDatastore10A
#######################################################################
# spec is created in virtual cluster Policies and Profiles
#######################################################################
$netmask = "255.255.255.0"
$gateway = "10.10.10.1"
$vm_networkname = "VM Network"
$spec = "vm-worker"
$vm_list = Import-CSV C:\Users\Administrator\vm.csv
$dns_primary = "8.8.8.8"
$dns_secondary = "4.4.4.4"
$location = "TestFolder"
$cpu_per_vm = 8
$vm_clone = "vm-worker-gold"
$memory_in_mb = 24000
#######################################################################
$change_vm_name=1
$vm_networkname_temp="VM Network" # temporarily change network name
$action=3 # 1:migrate vm
          # 2:clone vm
          # 3:customize vm
          # 4:move to folder
          # 5:change memory
#######################################################################

foreach ($item in $vm_list) {
    $vm_name = $item.vm_name
    $vm_name_new = $item.vm_name
    $vm_host = $item.vm_host
    $vm_datastore = $item.vm_datastore
    $vm_ip = $item.vm_ip

    echo "---------------------------------------------"
    echo "action=$action"

    if ($action -eq 1) {
       echo "---------------------------------------------"
        echo "::::Migrating $vm_name to $vm_host $vm_datastore"
        Stop-VM -VM $vm_name -Confirm:$False
        Get-VM $vm_name | Move-VM -Destination (Get-VMHost $vm_host) -Datastore $vm_datastore

    } else {
    
        echo "---------------------------------------------"
        echo "::::Creating temporary spec for new vm:  $vm_name ..."
        $spec_name="tempSpec"+(Get-Random)

        echo "::::Creating temporary spec $spec_name"
        Get-OSCustomizationSpec -Name $spec | New-OSCustomizationSpec -Name $spec_name -Type NonPersistent
        Get-OSCustomizationSpec -Name $spec_name | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $vm_ip -SubnetMask $netmask -DefaultGateway $gateway

        echo "::::Get customized temp_spec $temp_spec"
        $temp_spec = Get-OSCustomizationSpec -Name $spec_name

        if ($action -eq 2) {
            echo "::::Creating new vm $vm_name"
            echo "New-VM -Name $vm_name -VM $vm_clone -VMHost $vm_host -Datastore $vm_datastore -Location $location -OsCustomizationSpec $temp_spec -Confirm:$False"
            New-VM -Name $vm_name -VM $vm_clone -VMHost $vm_host -Datastore $vm_datastore -Location $location -OsCustomizationSpec $temp_spec -Confirm:$False -RunAsync
            $sleep = 5
            echo "::::Sleep $sleep seconds"
            Start-Sleep -Seconds $sleep
        }

        if ($action -eq 3) {
            echo "---------------------------------------------"
            echo "::::Stopping vm: $vm_name ..."
            Stop-VM -VM $vm_name -Confirm:$False

            if ($vm_networkname_temp -ne "") {
                echo "::::Temporarily change network name to $vm_networkname_temp"
                Get-VM $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "$vm_networkname_temp" -Confirm:$False
            }

            echo "---------------------------------------------"
            echo "::::Move VM to new Host and Datastore $vm_name CMD=Get-VM $vm_name | Move-VM -Destination (Get-VMHost $vm_host) -Datastore $vm_datastore"
            Get-VM $vm_name | Move-VM -Destination (Get-VMHost $vm_host) -Datastore $vm_datastore

            echo "---------------------------------------------"
            echo "::::Move VM to folder $location"
            Get-VM $vm_name | Move-VM -Destination $location -Datastore $vm_datastore

            echo "---------------------------------------------"
            echo "::::Setting vm spec on $vm_name"
            Set-VM -VM $vm_name -Confirm:$False -OSCustomizationSpec $temp_spec

            echo "---------------------------------------------"
            echo "::::Changing network adapter"
            Get-VM $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "$vm_networkname" -Confirm:$False

            echo "---------------------------------------------"
            echo "::::Changing CPU number to $cpu_per_vm"
            Set-VM -VM $vm_name -NumCpu $cpu_per_vm -Confirm:$False

            if ($change_vm_name -eq 1) {
                echo "---------------------------------------------"
                Set-VM -VM $vm_name -Name $vm_name_new -Confirm:$False
                echo "::::Changed VM name from $vm_name to $vm_name_new"
                $vm_name=$vm_name_new
            }
        }

        if ($action -eq 4) {
            echo "---------------------------------------------"
            echo "::::Move VM to folder $location"
            Get-VM $vm_name_new | Move-VM -Destination $location -Datastore $vm_datastore
        }

        if ($action -eq 5) {
            echo "---------------------------------------------"
            echo "::::Stopping vm: $vm_name ..."
            Stop-VM -VM $vm_name -Confirm:$False
            echo "::::Changing vm memory: $vm_name ..."
            Set-VM -VM $vm_name -MemoryMB $memory_in_mb -Confirm:$False -RunAsync
        }

        echo "---------------------------------------------"
        echo "::::Clean up temporary spec $spec_name"
        Remove-OSCustomizationSpec -Confirm:$False -customizationSpec (Get-OSCustomizationSpec -name $spec_name)
    }
    
    echo "---------------------------------------------"
    echo "::::Start VM $vm_name"
    Start-VM $vm_name -Confirm:$False -RunAsync
}
echo "::::Done!"
