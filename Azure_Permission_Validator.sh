#!/bin/bash
# Fail the script in case any of the commands get an error
set -e 

# Please add the properly name used for Custom Role and App Registration from Cloud Conformity in your account for validation
export CUSTOM_ROLE="NAME-CUSTOM-ROLE"
export APP_NAME="NAME-APP-REGISTRATION"

# Ask User Input for the App Registration Name
echo "Running the script for Onboarding accounts"

# Export App Registration ID and Active Directory ID to variables
export AD_ID=`az account show --query tenantId --output tsv`
export APP_ID=`az ad app list --display-name "$APP_NAME" | grep appId | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`

# Export All Subscriptions ID's to an Array and Count to a Variable
az account list --refresh > /dev/null
export SUBSCRIPTIONS=(`az account list | grep id | cut -d ":" -f2 | grep -o '".*"' | sed 's/^"\(.*\)".*/\1/'`)
export NUM_SUBS=${#SUBSCRIPTIONS[@]}

echo "Subscriptions with Custom Role Visible"
i=0
for (( i; i<$NUM_SUBS; i++ ))
do      
    export ROLE=`az role definition list --name "Custom Role - Cloud One Conformity" --subscription "${SUBSCRIPTIONS[i]}"`

    if [[ "$ROLE" != "[]" ]];
    then
        echo ${SUBSCRIPTIONS[i]} '= CUSTOM ROLE - VISIBLE' 
    else
        echo ${SUBSCRIPTIONS[i]} '= CUSTOM ROLE - NOT VISIBLE'
        SUBSCRIPTION_MISSING_ROLE_VISIBILITY+=${SUBSCRIPTIONS[i]}', '
    fi
done

echo ""
echo "Subscriptions with Role Assigments"

i=0
for (( i; i<$NUM_SUBS; i++ ))
do      
    export ROLE_ASSIGMENT=`az role assignment list --subscription "${SUBSCRIPTIONS[i]}" --role "$CUSTOM_ROLE" 2>/dev/null ` 
    
    if [[ -z "$ROLE_ASSIGMENT" ]];
    then
        echo ${SUBSCRIPTIONS[i]} '= ROLE ASSIGMENT - NO'
        SUBSCRIPTION_MISSING_ROLE_ASSIGMENT+=${SUBSCRIPTIONS[i]}', '
    else
        echo ${SUBSCRIPTIONS[i]} '= ROLE ASSIGMENT - YES' 
    fi
done

echo ""
echo "Subscriptions missing Custom Role visibility"
echo $SUBSCRIPTION_MISSING_ROLE_VISIBILITY | sed "s/,$//"

echo ""
echo "Subscriptions missing Role Assigments"
echo $SUBSCRIPTION_MISSING_ROLE_ASSIGMENT | sed "s/,$//"