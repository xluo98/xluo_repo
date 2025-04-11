#! /bin/bash

set -e

DEV_PATH="/Users/xLuo"

echo "Getting jwt..."

client_id=$(op read "op://Development - Shared/Coherent Path gRPC production credentials/CP_GRPC_CLIENT_ID")
client_secret=$(op read "op://Development - Shared/Coherent Path gRPC production credentials/CP_GRPC_CLIENT_SECRET")

response=$(grpcurl -authority=grpc.coherentpath.com -cacert=${DEV_PATH}/cert-prod.pem -import-path=${DEV_PATH}/protos -proto=${DEV_PATH}/protos/protos/coherentpath/auth.proto -d "{\"client_id\": \"${client_id}\", \"client_secret\": \"${client_secret}\"}" grpc.coherentpath.com:443 coherentpath.auth.AuthService.TokenCreate)
echo $response

jwt=$(echo ${response} | jq '.accessToken')

proto_files=$(find ${DEV_PATH}/ink-api/movableink -type f -iname "*.proto")
arguments=$(echo "${proto_files}" | sed 's/^/-proto=/;s/\n/ /g')


exec grpcui \
-default-header "Authorization: Bearer ${jwt}" \
-authority=grpc.coherentpath.com \
-cacert=${DEV_PATH}/cert-prod.pem \
-import-path=${DEV_PATH}/ink-api \
${arguments} \
grpc.coherentpath.com:443