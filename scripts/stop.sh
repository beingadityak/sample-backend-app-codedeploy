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

# ./build_vars.sh

ServiceType_tag=$(get_ServiceTypeTag)
ServiceType_tag=`echo ${ServiceType_tag,,}`
case $ServiceType_tag in
    api)
        echo "Got tag: $ServiceType_tag"
        pm2 stop api
        pm2 delete api
        ;;
    cron)
        echo "Got tag: $ServiceType_tag"
        pm2 stop cron
        pm2 delete cron
        ;;
    queue)
        echo "Got tag: $ServiceType_tag"
        pm2 stop queue
        pm2 delete queue
        ;;
    *)
        echo "Got invalid tag!"
        ;;
esac