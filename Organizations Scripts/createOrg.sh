#!/bin/bash

MY_API_KEY="<YOUR_API_KEY_HERE>"
read -p "Enter organization name: " name_input

# read -p "Enter email: " email_input
# If you want to include an email as a parameter in the payload, just...
#... uncomment the `read -p` for emails & ainclude this in the JSON body: "email": "$email_input"

URL="<YOUR_URL_HERE>"

# Creates the JSON payload for POSTING an Organization
JSON_PAYLOAD=$(cat <<EOF
{
"name": "$name_input",
"members": [

]
}
EOF
)

# Send POST API Call
curl -X POST "$URL" \
     -H "X-Domino-Api-Key: $MY_API_KEY" \
     -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD"