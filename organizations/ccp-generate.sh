#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    local ORG=$1
    local CAP_ORG="$(tr '[:lower:]' '[:upper:]' <<< "${ORG:0:1}")${ORG:1}"
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORG_CAP}/$CAP_ORG/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    local ORG=$1
    local CAP_ORG="$(tr '[:lower:]' '[:upper:]' <<< "${ORG:0:1}")${ORG:1}"
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORG_CAP}/$CAP_ORG/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}


ORG=manufacturer
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/${ORG}.com/tlsca/tlsca.${ORG}.com-cert.pem
CAPEM=organizations/peerOrganizations/${ORG}.com/ca/ca.${ORG}.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.yaml

ORG=retailer
P0PORT=9051
P1PORT=10051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/${ORG}.com/tlsca/tlsca.${ORG}.com-cert.pem
CAPEM=organizations/peerOrganizations/${ORG}.com/ca/ca.${ORG}.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.yaml

ORG=customer
P0PORT=11051
P1PORT=12051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/${ORG}.com/tlsca/tlsca.${ORG}.com-cert.pem
CAPEM=organizations/peerOrganizations/${ORG}.com/ca/ca.${ORG}.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" >organizations/peerOrganizations/${ORG}.com/connection-${ORG}.yaml
