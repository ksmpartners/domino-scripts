>Note: These scripts are specific to an Azure-based installation of Domino Data Lab. The scripts should be able to be adapted to any cloud provider, but are only guaranteed to work within Azure.
# Purpose
These scripts and yaml pipelines can be used to automate the scaling of compute resources for a Domino Data Lab implementation. Doing so may save your organization's resources during idle times in the system. 

# Prerequisites
- A Domino Data Lab installation using Azure cloud resources
- Access to the Azure resources used for the installation of Domino Data Lab
- A Service Principal (or equivalent) has been provisioned in your Azure tenancy with permissions to modify your Domino installation's node pools in AKS
- Ensure the scaleDownDomino.sh and scaleUpDomino.sh scripts are both executable by running `chmod +x <filename>` from the project directory in a terminal 

# Usage
- Replace the values in all files surrounded by `<>` with your organization's information
- Create two Azure pipelines using the system-scale-up and system-scale-down.yaml files
- Enable variable group access to the pipelines for the group containing the Service Principal's secrets
- Configure the CronJob values to suit your organization's specific timing needs 
  - for example, the default schedule is set to run the scale-down at 1 AM, UTC (9 PM EST), Tuesday-Saturday.
	`cron: "0 1 * * Tue,Wed,Thu,Fri,Sat"`
- Determine the extent of how you would like to scale your Domino system 
  - The example in this project assumes a small implementation with the compute nodes scaling up to only 4. Adjust these numbers based on your organizational needs. 
	
> Note: Your system will still require the Azure default `system` node pool even after you have scaled down your domino `platform` and `compute` node pools. [From Azure's AKS documentation](https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli): "Every AKS cluster must contain at least one system node pool with at least two nodes."
