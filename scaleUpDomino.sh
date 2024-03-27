#!/bin/bash
dominoUrl=<your domino URL>
dominoActive=0
runTime=0

#Log in to Azure CLI
az login --service-principal -u <Application (Client ID) value for Service Principal with permissions to modify Domino Azure Resources> -p <Service Principal password for SP with permissions to modify the Azure resources> --tenant <Your organization's Azure Tenant ID value>

#Enable compute1, computexxl1, and platform1 autoscaling
az aks nodepool update --resource-group <Your org's Domino Azure Resource Group> --cluster-name <Your org's Domino cluster name> --name compute1 --enable-cluster-autoscaler --min-count 1 --max-count 6

az aks nodepool update --resource-group <Your org's Domino Azure Resource Group> --cluster-name <Your org's Domino cluster name> --name computexxl1 --enable-cluster-autoscaler --min-count 0 --max-count 2

az aks nodepool update --resource-group <Your org's Domino Azure Resource Group> --cluster-name <Your org's Domino cluster name> --name platform1 --enable-cluster-autoscaler --min-count 4 --max-count 5
echo "Scaling node pools, please wait for confirmation of Domino service."

#Wait for 200 response. If loop execution exceeds an hour, break out and throw error to terminate pipeline. 
while true; do
  statusCode=$(curl -sL -w "%{http_code}" "$dominoUrl" -o /dev/null)

  if [ $statusCode -ne 200 ]; then
    echo "Status Code: $statusCode"
  else
    echo "$dominoUrl is operational with status code $statusCode"
    break
  fi

  sleep 180s
  runTime=$((runTime + 180))

  if [ $runTime -ge 3600 ]; then
    echo "Script running for over an hour. Terminating pipeline run."
    echo "##vso[task.logissue type=error]scale-up ran for over an hour."
    exit 1
  fi
done
