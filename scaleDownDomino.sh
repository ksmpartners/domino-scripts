#!/bin/bash

#Log in to Azure CLI
az login --service-principal -u <Application (Client ID) value for Service Principal with permissions to modify Domino Azure Resources> -p <Service Principal password for SP with permissions to modify the Azure resources> --tenant <Your organization's Azure Tenant ID value>

#Disable compute node pool autoscaling
az aks nodepool update \
  --resource-group <Your organization's Domino Azure Resource Group> \
  --cluster-name <Your organization's Domino cluster name> \
  --name compute1 \
  --disable-cluster-autoscaler

  az aks nodepool update \
  --resource-group <Your organization's Domino Azure Resource Group> \
  --cluster-name <Your organization's Domino cluster name> \
  --name computexxl1 \
  --disable-cluster-autoscaler

  az aks nodepool update \
  --resource-group <Your organization's Domino Azure Resource Group> \
  --cluster-name <Your organization's Domino cluster name> \
  --name platform1 \
  --disable-cluster-autoscaler  

#Retrieve and drain platform node pool
nodes=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep aks-platform)
echo "Draining the following platform nodes to enable scale-down of platform node pool: $nodes"
for node in $nodes; do
  echo "Draining platform node $node..."
  kubectl drain $node --disable-eviction=true --force=true --ignore-daemonsets=true --grace-period=5 --delete-emptydir-data
done

#Scale down Domino User Node Pools to 0
echo "Scaling down computexxl node pool"
az aks nodepool scale --name computexxl1 --cluster-name <Your organization's Domino cluster name> --resource-group <Your organization's Domino Azure Resource Group> --node-count 0
echo "Scaling down compute node pool"
az aks nodepool scale --name compute1 --cluster-name <Your organization's Domino cluster name> --resource-group <Your organization's Domino Azure Resource Group> --node-count 0
echo "Scaling down platform node pools"
az aks nodepool scale --name platform1 --cluster-name <Your organization's Domino cluster name> --resource-group <Your organization's Domino Azure Resource Group> --node-count 0
echo "Node pools scaled"
