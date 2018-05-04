#!/bin/bash
#export NEW_AMI=$(cat manifest.json | jq -r .builds[].artifact_id | sed s/us-west-2://)
export NEW_AMI=$(jq -r '.builds[].artifact_id' manifest.json | cut -d':' -f2)
echo "From shell script - packer post: ${NEW_AMI}"
#echo "From shell script - packer post: ${NEW_AMI2}"
echo -n $NEW_AMI > ami.txt