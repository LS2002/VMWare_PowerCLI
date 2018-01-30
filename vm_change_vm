#######################################################################
# WARNING: do not run the script without consent from vm owner
#
# SSH to test-vc     : ssh administrator@test-virtual-cluster-ip
# Start Powercli    : c:\pcli.bat
# Connect to test-vc : c:\connectvc.ps1
# Run this script   : c:\vm_change_vm.ps1
#######################################################################

$cpu_amount = 8
$network_name = "VM Network"
$vm_memory = 20

$prefix="vm-worker-"
$host_id="0"
$action=9 # 1:change cpu
          # 2:delete vm
          # 3:start vm
          # 4:stop vm,
          # 5:change name
          # 6:toggle memory reserve
          # 7:reboot
          # 8:set network
          # 9:change memory

For($I=1;$I -le 120;$I++){
    if ($I -lt 10) {
        $host_id="00"+$I
    }elseif($I -lt 100){
        $host_id="0"+$I
    }else{
        $host_id=$I
    }

    $vm_name=$prefix+$host_id

    if ($action -eq 1) {
        echo "------------------------------------------------"
        echo "::::Changing CPU on $vm_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Set-VM.html
        Set-VM -VM $vm_name -NumCpu $cpu_amount -Confirm:$False
    }

    if ($action -eq 2) {
        echo "------------------------------------------------"
        echo "::::Stopping $vm_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Stop-VM.html
        Stop-VM $vm_name -Confirm:$False
        echo "::::Removing $name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Remove-VM.html
        Remove-VM -VM $vm_name -DeletePermanently -Confirm:$False
    }

    if ($action -eq 3) {
        echo "------------------------------------------------"
        echo "::::Starting $vm_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Start-VM.html
        Start-VM $vm_name -Confirm:$False -RunAsync
    }

    if ($action -eq 4) {
        echo "------------------------------------------------"
        echo "::::Stopping $vm_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Stop-VM.html
        Stop-VM -VM $vm_name -Confirm:$False -RunAsync
    }

    if ($action -eq 5) {
        echo "------------------------------------------------"
        $prefix_new="vm-worker-new-"
        $host_id_new=$I
        $vm_new_name=$prefix_new+$host_id_new
        echo "::::Changing $vm_name to new name $vm_new_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Set-VM.html
        Stop-VM -VM $vm_name -Confirm:$False
        Set-VM $vm_name -name $vm_new_name -Confirm:$False
        Start-VM $vm_new_name
    }

    if ($action -eq 6) {
        echo "------------------------------------------------"
        echo "::::Toggle Memory Reservation for $vm_name"
        Stop-VM $vm_name -Confirm:$False
        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.memoryReservationLockedToMax = $true
        (Get-VM $vm_name).ExtensionData.ReconfigVM_Task($spec)
    }

    if ($action -eq 7) {
        echo "------------------------------------------------"
        echo "::::Rebooting $vm_name"
        Stop-VM $vm_name -Confirm:$False
        Start-VM $vm_name -Confirm:$False -RunAsync
    }

    if ($action -eq 8) {
        echo "------------------------------------------------"
        $network_new = $network_name
        echo "::::Setting $vm_name network to $network_new"
        Get-VM $vm_name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "$network_new" -Confirm:$False -RunAsync
    }

    if ($action -eq 9) {
        echo "------------------------------------------------"
        echo "::::Changing Memory on $vm_name"
        # https://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Set-VM.html
        Stop-VM $vm_name -Confirm:$False
        Set-VM -VM $vm_name -MemoryGB $vm_memory -Confirm:$False

        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.memoryReservationLockedToMax = $true
        (Get-VM $vm_name).ExtensionData.ReconfigVM_Task($spec)

        Start-VM $vm_name -Confirm:$False -RunAsync
    }
}
echo "::::Done!"
