#!/bin/bash

##Goals
##Simplify org onboarding for Admins
##Be able to add/remove users from org with few button clicks (not having to log on to Domino)


##Prerequisites for updating an organization
#1) Script executor needs Domino SysAdmin role (to retrieve orgs in step 2 below)
#2) identify organizationUserId: curl -X GET "https://<Domino-URL>/v4/organizations" -H  "accept: application/json"
#3) identify the user(s) ID(s) to add to organization identified in step 2 above
#4) Admin User executing this script should create an environment variable on their local machine called DOMINO_API_KEY (create an API key in the Domino UI if necessary)
#To add/change an environment variable permanently in Windows (so that it is available to ALL the Windows' processes/users and stayed across boots):

#    Launch "Control Panel"
#    "System"
#    "Advanced system settings"
#    Switch to "Advanced" tab
#    "Environment variables"
#    Choose "System Variables" (for all users)
#    To add a new environment variable:
#        Choose "New"
#        Enter the variable "Name" and "Value"



#Variables
DOMINO_URL=https://domino.ksmpartners.com
SAMPLE_ORG_ID=67f952aff8b93f4d8ef44670

read -p "Enter comma-separated list of IDs of users to add\n e.g., 1,2,3" usersToAdd
read -p "Enter comma-separated list of IDs of users to remove" usersToRemove

newUsersJson=""


##Create user insert record json
# Split the input into an array based on the comma
IFS=', ' read -r -a userValues <<< "$usersToAdd"

# Loop through each value and insert it into the template
for userID in "${userValues[@]}"
do
    # Trim any leading or trailing whitespace
    userID=$(echo $user | xargs)
    
	if [ -z "$newUserJson" ]; then
		# Insert each value into the template and print
		newUsersJson="$newUserJson{\"id\":$userID,\"role\":\"Member\"}"
	else 	
		newUsersJson="$newUserJson, {\"id\":$userID,\"role\":\"Member\"}"
	fi
done

echo $newUserJson

##Get list of organization users

organizationCurrentUsers=$(curl --location --request GET "$DOMINO_URL/v4/organizations/$SAMPLE_ORG_ID" \
--header "X-Domino-Api-Key: $DOMINO_API_KEY")

##Append new user(s) to organizationCurrentUsers list
#organizationUsersListNewMembers=$organizationCurrentUsers

#sample JSON value of organizationCurrentUsers
#{"id":"67f952aff8b93f4d8ef44671","name":"DATA_ADMINISTRATORS","organizationUserId":"67f952aff8b93f4d8ef44670","members":[{"id":"65a17f9c375051686550cc4e","role":"Member"},{"id":"667c294cf431c9032dff8c36","role":"Admin"}]}

##TODO: parse the above string for just the values after "members". Then concatenate the new usersToAdd value(s). Those values will need to be formatted properly like the below request body. 

##Add user to organization
#curl --location --request PUT "$DOMINO_URL/v4/organizations/$SAMPLE_ORG_ID/members" \
#--header 'X-Domino-Api-Key: ' \
#--header 'Content-Type: application/json' \
#--data '{
#  "members": [
#    {
#      "id": "674de32010cb4974f84cc159",
#      "role": "Admin"
#    }
#  ]
#}'





