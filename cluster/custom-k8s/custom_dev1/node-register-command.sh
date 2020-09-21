#!/bin/bash
rancher_api_url='https://demo.cnrancher.com'
rancher_api_key='token-5kphs:kthp4682rd98jr8dtcgsxqp9twrvdwhgqh2tkrr2x4gv6mrtncgmdt'

cluster_name=`echo custom_dev1 | sed 's/_/-/g' `

cluster_ID=$( curl -s -k -H "Authorization: Bearer ${rancher_api_key}" ${rancher_api_url}/v3/clusters | jq -r ".data[] | select(.name == \"$cluster_name\") | .id" )

CREATEDTS=$( curl -s -k -H "Authorization: Bearer ${rancher_api_key}" ${rancher_api_url}/v3/clusters/${cluster_ID}/clusterregistrationtokens | jq -r '[ .data[].createdTS ] | max' );

# nodeCommand
curl -s -k -H "Authorization: Bearer ${rancher_api_key}" ${rancher_api_url}/v3/clusters/${cluster_ID}/clusterregistrationtokens | jq --compact-output --raw-output ".data[] | select( .createdTS == "$CREATEDTS" ) .nodeCommand"


