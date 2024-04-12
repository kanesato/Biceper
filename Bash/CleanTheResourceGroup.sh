RunBastionFLG=1
RunNSGFLG=1
RunPrivateEndpointFLG=1
RunVmFLG=1
RunNicFLG=1
RunDiskFLG=1
RunSQLDatabaseFLG=1
RunDNSResolverFLG=1

deleteFLG=1
# --- This script is used to delete all resources in the resource group ---
subscriptionName="Skaneshiro-external-sub-1"
resourceGroupName="Bicep-fundermental-resourcegroup"

# --- delete Bastion -------
echo "Getting Bastion list"
echo " "
if (( $RunBastionFLG == 1))
then
    items=$(az network bastion list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
    for id in ${items[@]}
    do
        echo "Deleting Bastion with Id: "$id
        az network bastion delete --ids $id
        wait
        echo "Deleted Bastion with Id: "$id
        echo " "
    done  
fi

# --- delete DNS Private resolver inbount && outbound endpoind-------
echo "Getting DNS Private resolver list"
echo " "
if (( $RunDNSResolverFLG == 1))
then
    DPRs=$(az dns-resolver list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].{Name:name}" -o tsv)
    for name in ${DPRs[@]}
    do
        # Delete DNS Private resolver inbound-endpoint
        echo "Getting DNS Private resolver inbound-endpoint list attached to the DNS Private resolver: "$name""
        echo " "
        DPRinbounds=$(az dns-resolver inbound-endpoint list --resource-group $resourceGroupName --subscription $subscriptionName --dns-resolver-name $name --query "[].id" -o tsv)
        for id in ${DPRinbounds[@]}
        do
            echo "Deleting DNS Private resolver inbound-endpoint with Id: "$id
            az dns-resolver inbound-endpoint delete --ids $id --yes
            wait
            echo "Deleted DNS Private resolver inbound-endpoint with Id: "$id
            echo " "
        done

        # Get DNS Private resolver rule-sets
        echo "Getting DNS Private resolver rule-sets attached to the DNS Private resolver: "$name""
        echo " "
        DPRrulesets=$(az dns-resolver forwarding-ruleset list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
        for id in ${DPRrulesets[@]}
        do
            echo "Deleting DNS Private resolver rule-sets with Id: "$id
            az dns-resolver forwarding-ruleset delete --ids $id --yes
            wait
            echo "Deleted DNS Private resolver rule-sets with Id: "$id
            echo " "            
        done

        # Delete DNS Private resolver network-link
        echo "Getting DNS Private resolver network-link attached to the DNS Private resolver: "$name""
        echo " "
        DPRinbounds=$(az dns-resolver inbound-endpoint list --resource-group $resourceGroupName --subscription $subscriptionName --dns-resolver-name $name --query "[].id" -o tsv)
        for id in ${DPRinbounds[@]}
        do
            echo "Deleting DNS Private resolver inbound-endpoint with Id: "$id
            az dns-resolver inbound-endpoint delete --ids $id --yes
            wait
            echo "Deleted DNS Private resolver inbound-endpoint with Id: "$id
            echo " "
        done



        # Delete DNS Private resolver outbound-endpoint
        echo "Getting DNS Private resolver outbound-endpoint list attached to the DNS Private resolver: "$name""
        echo " "
        DPRoutbounds=$(az dns-resolver outbound-endpoint list --resource-group $resourceGroupName --subscription $subscriptionName --dns-resolver-name $name --query "[].id" -o tsv)
        for id in ${DPRoutbounds[@]}
        do
            echo "Deleting DNS Private resolver outbound-endpoint with Id: "$id
            az dns-resolver outbound-endpoint delete --ids $id --yes
            wait
            echo "Deleted DNS Private resolver outbound-endpoint with Id: "$id
            echo " "
        done
    done
fi

wait

# --- delete all DNS Private resolver -------
echo "Getting DNS Private resolver list"
echo " "
if (( $RunDNSResolverFLG == 1))
then
    items=$(az dns-resolver list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
    for id in ${items[@]}
    do
        echo "Deleting DNS Private resolver with Id: "$id
        az dns-resolver delete --ids $id --yes
        wait
        echo "Deleted DNS Private resolver with Id: "$id
        echo " "
    done
fi

echo "■ Start deleting all NSG in Resource Group :["$resourceGroupName"]"
if (( $RunNSGFLG == 1))
then
    #--- Detach all nsgs -------
    echo "Getting vnet list in the resource group: "$resourceGroupName""
    echo " "
    vnets=$(az network vnet list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].{Name:name}" -o tsv)
    wait    # wait for the vnet list

    for vnet in $vnets
    do 
        ### detach nsg from each subnet and delete every subnet of the Spoke vnet
        echo "Getting subnet list in the resource group: "$resourceGroupName""
        echo " "
        subnets=$(az network vnet subnet list --resource-group $resourceGroupName --subscription $subscriptionName --vnet-name $vnet --query "[].{Name:name}" -o tsv)

        # detach nsg from each subnet
        for subnet in $subnets
        do
            echo "Detaching nsg from subnet: $subnet"
            echo " "
            az network vnet subnet update --resource-group $resourceGroupName --subscription $subscriptionName --vnet-name $vnet --name $subnet --network-security-group null
                wait    # wait for the subnet update
            echo "Detached nsg from subnet: $subnet"
            echo " "
        done
    done
fi

#--- Delete all Private Endpoint -------
echo "■ Start deleting all Private Endpoint in Resource Group :["$resourceGroupName"]"
echo " "
if  (( $RunPrivateEndpointFLG == 1 ))
then
    echo "Getting PE list in the resource group: "$resourceGroupName""
    echo " "
    items=$(az network private-endpoint list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${items[@]}
    do
        echo "Deleting Private Endpoint with Id: "$id
        echo " "
        az network private-endpoint delete --ids $id
        wait    # wait for the PE deletion
        echo "Deleted Private Endpoint with Id: "$id
        echo " "
    done
fi

#--- delete all VMs -------
echo "Start deleting all VMs in Resource Group :["$resourceGroupName"]"
echo " "
if  (( $RunVmFLG == 1 ))
then
    echo "Getting vm list in the resource group: "$resourceGroupName""
    echo " "
    VMs=$(az vm list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${VMs[@]}
    do
        echo "Deleting VM with Id: "$id
        echo " "
        az vm delete --ids $id --yes
        wait 
        echo "Deleted VM with Id: "$id
        echo " "
    done
fi

#--- delete all Nics -------
echo "Start deleting all Nics in Resource Group :["$resourceGroupName"]"
echo " "
if  (( $RunNicFLG == 1 ))
then
    echo "Getting nig list in the resource group: "$resourceGroupName""
    echo " "
    NIGs=$(az network nic list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${NIGs[@]}
    do
        echo "Deleting NIC with Id: "$id
        echo " "
        az network nic delete --ids $id
        wait    # wait for the nsg deletion
        echo "Deleted NIC with Id: "$id
        echo " "
    done
fi

#--- delete all NSGs -------
echo "Start deleting all NSGs in Resource Group :["$resourceGroupName"]"
echo " "
if  (( $RunNSGFLG == 1 ))
then
    echo "Getting nsg list in the resource group: "$resourceGroupName""
    echo " "
    nsgs=$(az network nsg list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${nsgs[@]}
    do
        echo "Deleting NSG with Id: "$id
        echo " "
        az network nsg delete --ids $id
        wait    # wait for the nsg deletion
        echo "Deleted NSG with Id: "$id
        echo " "
    done
fi

#--- delete all disks -------
echo "Start deleting all Disks in Resource Group :["$resourceGroupName"]"
echo " "
if (( $RunDiskFLG == 1))
then
    echo "Getting disk list in the resource group: "$resourceGroupName""
    echo " "
    disks=$(az disk list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${disks[@]}
    do 
        echo "Deleting disk with Id: "$id
        echo " "
        az disk delete --ids $id --yes
        wait   # wait for the disk deletion
        echo "Deleted disk with Id: "$id
        echo " "
    done
fi

#--- Deletet SQL Database ---
echo "Start deleting all SQL Databases from all SQL Servers in Resource Group :["$resourceGroupName"]"
echo " "
if (( $RunSQLDatabaseFLG == 1))
then
    echo "Getting sql server list"
    echo " "
    servers=$(az sql server list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].{Name:name}" -o tsv)

    for name in ${servers[@]}
    do 
        echo "Getting sql db list from the sql server"
        echo " "
        dbs=$(az sql db list --server $name --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

        for id in ${dbs[@]}
        do
            echo "Deleting sqldatabase with Id: "$id
            echo " "
            az sql db delete --ids $id --yes
            wait   # wait for the disk deletion
            echo "Deleted sqldatabase with Id: "$id
            echo " "
        done
    done
fi

#--- delete vpn gateway -------
echo "Start deleting all VPN Gateways in Resource Group :["$resourceGroupName"]"
echo "Getting VPN Gateway list"
echo " "
items=$(az network vnet-gateway list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
for id in ${items[@]}
do
    echo "Deleting VPN Gateway with Id: "$id
    az network vnet-gateway delete --ids $id
    wait
    echo "Deleted VPN Gateway with Id: "$id    
done

#--- Deletet SQL Server ---
echo "Start deleting all SQL Servers in Resource Group :["$resourceGroupName"]"
echo " "
if (( $RunSQLDatabaseFLG == 1))
then
    echo "Getting sql server list"
    echo " "
    servers=$(az sql server list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)

    for id in ${servers[@]}
    do
            echo "Deleting sql server with Id: "$id
            echo " "
            az sql server delete --ids $id --yes
            wait   # wait for the disk deletion
            echo "Deleted sql server with Id: "$id
            echo " "
    done
fi

#--- delete Log-Analytics -------
echo "Start deleting sql servers"
echo " "
if ((deleteFLG == 1))
then
    echo "Getting Log Analytics workspace list"
    echo " "
        items=$(az monitor log-analytics workspace list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
        for id in ${items[@]}
        do
            echo "Deleting Log-Analytics with Id: "$id
            az monitor log-analytics workspace delete --ids $id --yes
            wait
            echo "Deleted Log-Analytics with Id: "$id    
        done
    wait
fi
wait

#--- delete Storage Account -------
echo "Getting Storage Account list"
echo " "
items=$(az storage account list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
for id in ${items[@]}
do
    echo "Deleting Storage Account with Id: "$id
    az storage account delete --ids $id --yes
    wait
    echo "Deleted Storage Account with Id: "$id    
done


# --- delete Azure firewall -------
az network firewall delete --name 'poc-Firewall-Hub' --resource-group $resourceGroupName --subscription $subscriptionName
echo "Getting Azure firewall list"

    echo " "
    items=$(az network firewall list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
    for id in ${items[@]}
    do
        echo "Deleting Azure firewall with Id: "$id
        az network firewall delete --ids $id
        wait
        echo "Deleted Azure firewall with Id: "$id    
    done

# --- delete all Azure Firewall Policy -------
echo "Getting AFW Policy list"
echo " "
items=$(az network firewall policy list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
for id in ${items[@]}
do
    echo "Deleting AFW Policy with Id: "$id
    az network firewall policy delete --ids $id
    wait
    echo "Deleted AFW Policy with Id: "$id
    echo " "
done

# --- delete Public IP -------
echo "Getting Public IP list"

    echo " "
    items=$(az network public-ip list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
    for id in ${items[@]}
    do
        echo "Deleting Public IP with Id: "$id
        az network public-ip delete --ids $id
        wait
        echo "Deleted Public IP with Id: "$id    
    done

    # --- delete UDR -------
echo "Getting route-table list"

    echo " "
    items=$(az network route-table list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
    for id in ${items[@]}
    do
        echo "Deleting route-table with Id: "$id
        az network route-table delete --ids $id
        wait
        echo "Deleted route-table with Id: "$id    
    done

echo "Getting Private Zone list"
echo " "
items=$(az network private-dns zone list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].name" -o tsv)
for name in ${items[@]}
do
    entities=$(az network private-dns link vnet list --resource-group $resourceGroupName --subscription $subscriptionName -z $name --query "[].id" -o tsv)
    for id in ${entities[@]}
    do
        echo "Deleting Private Link with Id: "$id
        az network private-dns link vnet delete --ids $id --yes
        wait
        echo "Deleted Private Link with Id: "$id    
    done
    echo "Deleting Private Zone with Id: "$id
    az network private-dns zone delete --ids $id --yes
    wait
    echo "Deleted Private Zone with Id: "$id    
done

# --- delete all Private Zone -------
echo "Getting Private Zone list"
echo " "
items=$(az network private-dns zone list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
for id in ${items[@]}
do
    echo "Deleting Private Zone with Id: "$id
    az network private-dns zone delete --ids $id --yes
    wait
    echo "Deleted Private Zone with Id: "$id    
done

# --- delete all Virtual Network -------
echo "Getting VNet list"
echo " "
items=$(az network vnet list --resource-group $resourceGroupName --subscription $subscriptionName --query "[].id" -o tsv)
for id in ${items[@]}
do
    echo "Deleting VNet with Id: "$id
    az network vnet delete --ids $id
    wait
    echo "Deleted VNet with Id: "$id
    echo " "
done

# # --- delete all vnets -------
# az network vnet delete --name $hubvnetName --resource-group $resourceGroupName --subscription $subscriptionName
# wait    # wait for the vnet deletion
# az network vnet delete --name $spokevnetName --resource-group $resourceGroupName --subscription $subscriptionName
# wait    # wait for the vnet deletion