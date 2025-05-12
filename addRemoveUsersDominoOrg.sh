#!/bin/bash

##Prerequisites for updating an organization
#1) Script executor needs Domino SysAdmin role (to retrieve orgs in step 2 below)
#2) identify organization ID: curl -X GET "https://<Domino-URL>/v4/organizations" -H  "accept: application/json"
#3) identify the user(s) ID(s) to add to organization identified in step 2 above

##Add user to organization
curl --location --request PUT 'https://domino.ksmpartners.com/v4/organizations/68191a6f47f11d5feef42ab2/members' \
--header 'X-Domino-Api-Key: ' \
--header 'Content-Type: application/json' \
--data '{
  "members": [
    {
      "id": "667c294cf431c9032dff8c36 (Matt's ID - can use if you want)",
      "role": "Member"
    }
  ]
}'