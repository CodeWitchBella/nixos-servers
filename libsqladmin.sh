#!/bin/sh

cd secrets
agenix -d libsql-jwt.key.age > libsql-jwt.key
jwt=`nix run nixpkgs#step-cli \
    -- crypto jwt sign \
    --key libsql-jwt.key --iss me@isbl.cz \
    --aud https://test.db.isbl.cz --sub rw \
    --exp $(date --date='next year' +"%s")`
rm libsql-jwt.key
cd ..

delete() {
    curl \
        -v \
        -X DELETE \
        -d '{}' \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $jwt" \
        https://db.isbl.cz/v1/namespaces/$1
}

create() {
    curl \
        -v \
        -X POST \
        -d '{}' \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $jwt" \
        https://db.isbl.cz/v1/namespaces/$1/create
}

# delete test
# create test
echo $jwt
