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
SAMPLE_ORG_ID=6813a563292f254e3d945b11
logFile="user_changes.log"
echo "=== User Changes Log: $(date) ===" > "$logFile"

read -p "Enter comma-separated list of IDs of users to add\n e.g., 1,2,3" usersToAdd
read -p "Enter comma-separated list of IDs of users to remove" usersToRemove

newUsersJson=""


##Create user insert record json
# Split the usersToAdd input into an array based on the comma
IFS=', ' read -r -a userAddValues <<< "$usersToAdd"

# Split the usersToRemove input into an array based on the comma
IFS=', ' read -r -a userRemoveValues <<< "$usersToRemove"

# Loop through each value and insert it into the template
for userID in "${userAddValues[@]}"
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

# ##Get list of organization users
# organizationCurrentUsers=$(curl --location --request GET "$DOMINO_URL/v4/organizations/$SAMPLE_ORG_ID" \
# --header "X-Domino-Api-Key: $DOMINO_USER_API_KEY")

##Get list of Domino users
currentDomionUsers=$(curl --location --request GET "$DOMINO_URL/v4/users" \
--header "X-Domino-Api-Key: $DOMINO_USER_API_KEY")

# echo $currentDomionUsers

##Format JSON for BASH?
flatJson=$(echo "$currentDomionUsers" | tr -d '\n')


##----------------------------------------ADD--------------------------------------------------

##Loop - Retrieve Domino user ids matching emails being added to organization)
for email in "${userAddValues[@]}"; do
  id=$(echo "$flatJson" | grep -o "{[^}]*\"email\":\"$email\"[^}]*}" \
       | grep -o '"id":"[^"]*"' \
       | cut -d':' -f2 \
       | tr -d '"')
  if [ -n "$id" ]; then
    userIdEmailAdd+=("$email|$id")
  fi
done

# Add user ids to organization
for pair in "${userIdEmailAdd[@]}"; 
do
  email="${pair%%|*}"
  id="${pair##*|}"
  echo "Added user ID $id (email: $email)" to group $SAMPLE_ORG_ID | tee -a "$logFile"
  
  # Create JSON payload
  jsonPayloadAdd=$(printf '{
  "userId": "%s", 
  "organizationRole": "Member"
  }' "$id")
  #Add
  curl --location --request PUT "$DOMINO_URL/api/organizations/v1/organizations/$SAMPLE_ORG_ID/user" \
  --header "X-Domino-Api-Key: $DOMINO_USER_API_KEY" \
  --header 'Content-Type: application/json' \
  --data-raw "$jsonPayloadAdd"
done

##---------------------------------------REMOVE------------------------------------------------

##Loop - Retrieve Domino user ids matching emails being removed from organization)
for email in "${userRemoveValues[@]}"; do
  id=$(echo "$flatJson" | grep -o "{[^}]*\"email\":\"$email\"[^}]*}" \
       | grep -o '"id":"[^"]*"' \
       | cut -d':' -f2 \
       | tr -d '"')
  if [ -n "$id" ]; then
    userIdEmailRemove+=("$email|$id")
  fi
done

# Remove user ids from organization
for pair in "${userIdEmailRemove[@]}"; 
do
  email="${pair%%|*}"
  id="${pair##*|}"

  echo "Removed user ID $id (email: $email)" from group $SAMPLE_ORG_ID | tee -a "$logFile"
  
  #Remove
  curl --location --request DELETE "$DOMINO_URL/api/organizations/v1/organizations/$SAMPLE_ORG_ID/user?memberToRemoveId=$id&organizationId=$SAMPLE_ORG_ID" \
  --header "X-Domino-Api-Key: $DOMINO_USER_API_KEY" \
  --header 'Content-Type: application/json' \
  --data ''
done

echo $jsonPayloadAdd

## For Testing
  # pvanbeever@ksmpartners.onmicrosoft.com
  # lpham@ksmpartners.onmicrosoft.com
  # mschwartz@ksmpartners.onmicrosoft.com
# Expected Ids:
  # 674de32010cb4974f84cc159 - P
  # 674de31e6253f73bcd193211 - L
  # 667c294cf431c9032dff8c36 - M 

## Confirmation
##Get list of organization users
organizationCurrentUsers=$(curl --location --request GET "$DOMINO_URL/v4/organizations/$SAMPLE_ORG_ID" \
--header "X-Domino-Api-Key: $DOMINO_USER_API_KEY")
echo $organizationCurrentUsers


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





