#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=../organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem
export PEER0_MANUFACTURER_CA=../organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/ca.crt
export PEER0_RETAILER_CA=../organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/ca.crt
export PEER0_CUSTOMER_CA=../organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/ca.crt

# No need to modify files present in config path as we use separate configtx.yaml file and other variables are
# overridden while creating peer containers.
export FABRIC_CFG_PATH=../config/

export CHANNEL_NAME="supply-chain"

setGlobalsForPeer0Manufacturer() {
  export CORE_PEER_LOCALMSPID="ManufacturerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/manufacturer.com/users/Admin@manufacturer.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Manufacturer() {
  export CORE_PEER_LOCALMSPID="ManufacturerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/manufacturer.com/users/Admin@manufacturer.com/msp
  export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer0Retailer() {
  export CORE_PEER_LOCALMSPID="RetailerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/retailer.com/users/Admin@retailer.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer1Retailer() {
  export CORE_PEER_LOCALMSPID="RetailerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/retailer.com/users/Admin@retailer.com/msp
  export CORE_PEER_ADDRESS=localhost:10051
}

setGlobalsForPeer0Customer() {
  export CORE_PEER_LOCALMSPID="CustomerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CUSTOMER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/customer.com/users/Admin@customer.com/msp
  export CORE_PEER_ADDRESS=localhost:11051
}

setGlobalsForPeer1Customer() {
  export CORE_PEER_LOCALMSPID="CustomerMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CUSTOMER_CA
  export CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/customer.com/users/Admin@customer.com/msp
  export CORE_PEER_ADDRESS=localhost:12051
}

createChannel() {
  setGlobalsForPeer0Manufacturer

  peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer1.orderer.com \
    -f ../channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ../channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile "$ORDERER_CA"
}

joinChannel() {
  setGlobalsForPeer0Manufacturer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Manufacturer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Retailer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Retailer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Customer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Customer
  peer channel join -b ../channel-artifacts/$CHANNEL_NAME.block
}

updateAnchorPeers() {
  setGlobalsForPeer0Manufacturer
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer1.orderer.com -c $CHANNEL_NAME -f ../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile "$ORDERER_CA"

  setGlobalsForPeer0Retailer
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer1.orderer.com -c $CHANNEL_NAME -f ../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile "$ORDERER_CA"

  setGlobalsForPeer0Customer
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer1.orderer.com -c $CHANNEL_NAME -f ../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile "$ORDERER_CA"
}

createChannel
joinChannel
updateAnchorPeers
