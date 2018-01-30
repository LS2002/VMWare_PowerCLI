#######################################################################
# WARNING: do not run the script without consent from host owner
#
# SSH to test-vc     : ssh administrator@test-virtual-cluster-ip
# Start Powercli    : c:\pcli.bat
# Connect to test-vc : c:\connectvc.ps1
# Run this script   : c:\vm_change_host.ps1
#######################################################################
# sampe content of the csv file
# ip,datastore,new_ip
# 10.10.10.1,TestDatastore10A,10.20.20.1
#######################################################################

$host_list = Import-CSV C:\Users\Administrator\test_host.csv
$location = "CurrentCluster"
$datastore_prefix = "TestDatastore"
$company_license = "AB123-456CD-78EFG-9HIJK-0LMNO"
$action = 2 # 1:Add host, 
            # 2:Rename datastore
            # 3:Do both
            # 4:Add VMKernel NIC
            # 5:Move VMHost
            # 6:Reboot Host
$host_root_password = "abc123456"
$subnet_mask = "255.255.255.0"

foreach ($item in $host_list) {
    $host_name=$item.ip
    if ($action -eq 1 -or $action -eq 3){

        echo "=============================================="
        echo "Adding host $host_name"
        Add-VMHost -Name $host_name -Location $location -User root -Password $host_root_password -Force:$True

        echo "----------------------------------------------"
        echo "Setting License for $host_name"
        Set-VMHost -VMHost $host_name -LicenseKey $company_license -Confirm:$False
    }

    if ($action -eq 2 -or $action -eq 3){
        $datastore=$item.datastore
        echo "----------------------------------------------"
        echo "Renaming host $host_name datastore to $datastore"
        Get-VMHost -Name $host_name | Get-Datastore | Set-Datastore -Name $datastore -Confirm:$False
    }

    if ($action -eq 4) {
        $new_ip=$item.new_ip
        $vs=Get-VirtualSwitch -VMHost $host_name -Name vSwitch0
        New-VMHostNetworkAdapter -VMHost $host_name -VirtualSwitch $virtualSwitch -IP $new_ip -SubnetMask $subnet_mask
    }

    if ($action -eq 5) {
        $location = "NewCluster"
        echo "----------------------------------------------"
        echo "Moving host $host_name to $location"
        Set-VMHost -VMHost $host_name -LicenseKey $company_license -Confirm:$False
        Set-VMHost -VMHost $host_name -State Disconnected -Confirm:$False
        Move-VMHost -VMHost $host_name -Destination $location -Confirm:$False
        Set-VMHost -VMHost $host_name -State Connected -Confirm:$False -RunAsync
    }

     if ($action -eq 6) {
        echo "Rebooting $host_name"
        Restart-VMHost -VMHost $host_name -RunAsync -Confirm:$False
     }
}
