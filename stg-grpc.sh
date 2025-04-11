#! /bin/bash

set -e

# step 1 - 
# a. make sure script is in the same dev dir as the repos
# b. git clone repos: coherentpath / ink-api / protos
# c. make sure you save the credentails into cert files, ie cert-stg.pem (for stg / prod), in the same root dir (you can find the cert files in 1password, ie Coherent Path gRPC staging credentials)

# step 2 - make sure install below
# brew install op
# brew install grpcurl
# brew install grpcui
# brew install jq

# step 3 - this will redirect to onepassword auth

DEV_PATH="/Users/xLuo" # the root dir where you put your repos

echo "Getting jwt..."

client_id=$(op read "op://Development - Shared/Coherent Path gRPC staging credentials/COHERENTPATH_GRPC_CLIENT_ID")
client_secret=$(op read "op://Development - Shared/Coherent Path gRPC staging credentials/COHERENTPATH_GRPC_CLIENT_SECRET")

response=$(grpcurl -authority=grpc-stg.coherentpath.com -cacert=${DEV_PATH}/cert-stg.pem -import-path=${DEV_PATH}/protos -proto=${DEV_PATH}/protos/protos/coherentpath/auth.proto -d "{\"client_id\": \"${client_id}\", \"client_secret\": \"${client_secret}\"}" grpc-stg.coherentpath.com:443 coherentpath.auth.AuthService.TokenCreate)
echo $response

jwt=$(echo ${response} | jq '.accessToken')

proto_files=$(find ${DEV_PATH}/ink-api/movableink -type f -iname "*.proto")
arguments=$(echo "${proto_files}" | sed 's/^/-proto=/;s/\n/ /g')


exec grpcui \
-default-header "Authorization: Bearer ${jwt}" \
-authority=grpc-stg.coherentpath.com \
-cacert=${DEV_PATH}/cert-stg.pem \
-import-path=${DEV_PATH}/ink-api \
${arguments} \
grpc-stg.coherentpath.com:443