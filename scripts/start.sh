#!/bin/bash

AppLocation="/home/ubuntu/app"

function get_ServiceTypeTag() {
    METADATA_OUT=`curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document`
    INSTANCE_ID=`echo $METADATA_OUT | jq -r .instanceId`
    REGION=`echo $METADATA_OUT | jq -r .region`
    ServiceTypeTag=`aws ec2 describe-instances --region ${REGION} --instance-ids ${INSTANCE_ID} | jq -r '.Reservations[] | .Instances[] | (.Tags|from_entries|.ServiceType)'`
    echo $ServiceTypeTag
}

## Initialize NVM for the script
export NVM_DIR="/home/ubuntu/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 

cd $AppLocation
sudo rm -rf node_modules

npm install

# ./build_vars.sh

ServiceType_tag=$(get_ServiceTypeTag)
case ServiceType_tag in
    api)
        echo "Got tag: $ServiceType_tag"
        pm2 start ecosystem.config.js --env production --only api
        ;;
    cron)
        echo "Got tag: $ServiceType_tag"
        pm2 start ecosystem.config.js --env production --only cron
        ;;
    queue)
        echo "Got tag: $ServiceType_tag"
        pm2 start ecosystem.config.js --env production --only queue
        ;;
    *)
        echo "Got invalid tag!"
        ;;
esac