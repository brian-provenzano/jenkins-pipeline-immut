#!/bin/bash
export NEW_AMI=$(jq -r '.builds[].artifact_id' manifest.json | cut -d':' -f2)
echo "From shell script - packer post: ${NEW_AMI}"
echo -n $NEW_AMI > ami.txt