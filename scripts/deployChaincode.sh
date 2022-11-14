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

CHANNEL_NAME="supply-chain"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="../asset-transfer/product-chaincode/"
CC_NAME="product-chaincode"

packageChaincode() {
  rm -rf ../${CC_NAME}.tar.gz
  rm -rf ../log.txt
  peer lifecycle chaincode package ../${CC_NAME}.tar.gz \
    --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
    --label ${CC_NAME}_${VERSION}
  echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
  setGlobalsForPeer0Manufacturer
  peer lifecycle chaincode install ../${CC_NAME}.tar.gz
  echo "===================== Chaincode is installed on peer0.manufacturer ===================== "

  setGlobalsForPeer0Retailer
  peer lifecycle chaincode install ../${CC_NAME}.tar.gz
  echo "===================== Chaincode is installed on peer0.retailer ===================== "

  setGlobalsForPeer0Customer
  peer lifecycle chaincode install ../${CC_NAME}.tar.gz
  echo "===================== Chaincode is installed on peer0.customer ===================== "
}

queryInstalled() {
  setGlobalsForPeer0Manufacturer
  LOG_TXT_FILE="../log.txt"
  peer lifecycle chaincode queryinstalled >&$LOG_TXT_FILE
  cat $LOG_TXT_FILE
  PACKAGE_ID=$(grep -o -P "(?<=Package\sID:\s)${CC_NAME}_${VERSION}:.*(?=,\sLabel:\s${CC_NAME}_${VERSION})" $LOG_TXT_FILE | grep .)
  echo PackageID is \<"${PACKAGE_ID}"\>
  echo "===================== Query installed successful on peer0.manufacturer ===================== "
}

approveForMyOrgManufacturer() {
  setGlobalsForPeer0Manufacturer
  peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer1.orderer.com --tls \
    --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
    --init-required --package-id "${PACKAGE_ID}" \
    --sequence ${VERSION}
  echo "===================== chaincode approved from manufacturer ===================== "
}

approveForMyOrgRetailer() {
  setGlobalsForPeer0Retailer

  peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer1.orderer.com --tls $CORE_PEER_TLS_ENABLED \
    --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION} --init-required --package-id "${PACKAGE_ID}" \
    --sequence ${VERSION}

  echo "===================== chaincode approved from retailer ===================== "
}

approveForMyOrgCustomer() {
  setGlobalsForPeer0Customer

  peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer1.orderer.com --tls $CORE_PEER_TLS_ENABLED \
    --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION} --init-required --package-id "${PACKAGE_ID}" \
    --sequence ${VERSION}

  echo "===================== chaincode approved from customer ===================== "
}

checkCommitReadiness() {
  setGlobalsForPeer0Manufacturer
  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
    --peerAddresses localhost:7051 --tlsRootCertFiles "$PEER0_MANUFACTURER_CA" \
    --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
  echo "===================== checking commit readiness from manufacturer ===================== "
}

commitChaincodeDefinition() {
  setGlobalsForPeer0Manufacturer
  # 7051, 9051 and 11051 are endorsing peers
  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer1.orderer.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile "$ORDERER_CA" \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --peerAddresses localhost:7051 --tlsRootCertFiles "$PEER0_MANUFACTURER_CA" \
    --peerAddresses localhost:9051 --tlsRootCertFiles "$PEER0_RETAILER_CA" \
    --peerAddresses localhost:11051 --tlsRootCertFiles "$PEER0_CUSTOMER_CA" \
    --version ${VERSION} --sequence ${VERSION} --init-required
}

queryCommitted() {
  setGlobalsForPeer0Manufacturer
  peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
}

chaincodeInvokeInit() {
  setGlobalsForPeer0Manufacturer

  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer1.orderer.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_MANUFACTURER_CA \
    --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_RETAILER_CA \
    --peerAddresses localhost:11051 --tlsRootCertFiles "$PEER0_CUSTOMER_CA" \
    --isInit -c '{"function":"InitLedger","Args":[]}'
}

chaincodeQuery() {
  setGlobalsForPeer0Manufacturer

  # Query all assets
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["GetAllAssets"]}'
}

packageChaincode
installChaincode
queryInstalled
approveForMyOrgManufacturer
checkCommitReadiness
approveForMyOrgRetailer
checkCommitReadiness
approveForMyOrgCustomer
checkCommitReadiness
commitChaincodeDefinition
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeQuery
