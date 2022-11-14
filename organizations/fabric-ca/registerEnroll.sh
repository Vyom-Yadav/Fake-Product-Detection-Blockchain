#!/bin/bash

function createManufacturer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/manufacturer.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/peerOrganizations/manufacturer.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy manufacturer's CA cert to manufacturer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/tlscacerts/ca.crt"

  # Copy manufacturer's CA cert to manufacturer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.com/tlsca/tlsca.manufacturer.com-cert.pem"

  # Copy manufacturer's CA cert to manufacturer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.com/ca"
  cp "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.com/ca/ca.manufacturer.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/msp" --csr.hosts peer0.manufacturer.com --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls" --enrollment.profile tls --csr.hosts peer0.manufacturer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer0.manufacturer.com/tls/server.key"

  echo "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/msp" --csr.hosts peer1.manufacturer.com --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/msp/config.yaml"

  echo "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls" --enrollment.profile tls --csr.hosts peer1.manufacturer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.com/peers/peer1.manufacturer.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/users/User1@manufacturer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.com/users/User1@manufacturer.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.com/users/Admin@manufacturer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.com/users/Admin@manufacturer.com/msp/config.yaml"
}

function createRetailer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/retailer.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/retailer.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-retailer --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-retailer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-retailer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-retailer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-retailer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/peerOrganizations/retailer.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy retailer's CA cert to retailer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/retailer.com/msp/tlscacerts/ca.crt"

  # Copy retailer's CA cert to retailer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/retailer.com/tlsca/tlsca.retailer.com-cert.pem"

  # Copy retailer's CA cert to retailer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.com/ca"
  cp "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/retailer.com/ca/ca.retailer.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name retaileradmin --id.secret retaileradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/msp" --csr.hosts peer0.retailer.com --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls" --enrollment.profile tls --csr.hosts peer0.retailer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer0.retailer.com/tls/server.key"

  echo "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/msp" --csr.hosts peer1.retailer.com --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/msp/config.yaml"

  echo "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls" --enrollment.profile tls --csr.hosts peer1.retailer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/retailer.com/peers/peer1.retailer.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/users/User1@retailer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.com/users/User1@retailer.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://retaileradmin:retaileradminpw@localhost:8054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.com/users/Admin@retailer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/retailerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.com/users/Admin@retailer.com/msp/config.yaml"
}

function createCustomer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/customer.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/customer.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-customer --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-customer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-customer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-customer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-customer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/peerOrganizations/customer.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy customer's CA cert to customer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/customer.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/customer.com/msp/tlscacerts/ca.crt"

  # Copy customer's CA cert to customer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/customer.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/customer.com/tlsca/tlsca.customer.com-cert.pem"

  # Copy customer's CA cert to customer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/customer.com/ca"
  cp "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem" "${PWD}/organizations/peerOrganizations/customer.com/ca/ca.customer.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-customer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-customer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-customer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-customer --id.name customeradmin --id.secret customeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/msp" --csr.hosts peer0.customer.com --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/customer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls" --enrollment.profile tls --csr.hosts peer0.customer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer0.customer.com/tls/server.key"

  echo "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/msp" --csr.hosts peer1.customer.com --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/customer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/msp/config.yaml"

  echo "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls" --enrollment.profile tls --csr.hosts peer1.customer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/customer.com/peers/peer1.customer.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/users/User1@customer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/customer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/customer.com/users/User1@customer.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://customeradmin:customeradminpw@localhost:9054 --caname ca-customer -M "${PWD}/organizations/peerOrganizations/customer.com/users/Admin@customer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/customerOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/customer.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/customer.com/users/Admin@customer.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/orderer.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/orderer.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/ordererOrganizations/orderer.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/orderer.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/orderer.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/orderer.com/tlsca/tlsca.orderer.com-cert.pem"

  echo "Registering orderer1"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer1 --id.secret orderer1pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering orderer2"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret orderer2pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering orderer3"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret orderer3pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer1 msp"
  set -x
  fabric-ca-client enroll -u https://orderer1:orderer1pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/msp" \
    --csr.hosts orderer1.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/orderer.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/msp/config.yaml"

  echo "Generating the orderer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer1:orderer1pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls" \
    --enrollment.profile tls --csr.hosts orderer1.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer1.orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem"

  echo "Generating the orderer2 msp"
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/msp" \
    --csr.hosts orderer2.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/orderer.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/msp/config.yaml"

  echo "Generating the orderer2-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls" \
    --enrollment.profile tls --csr.hosts orderer2.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer2.orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem"

  echo "Generating the orderer3 msp"
  set -x
  fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/msp" \
    --csr.hosts orderer3.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/orderer.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/msp/config.yaml"

  echo "Generating the orderer3-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls" \
    --enrollment.profile tls --csr.hosts orderer3.orderer.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/orderer.com/orderers/orderer3.orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/orderer.com/users/Admin@orderer.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/orderer.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/orderer.com/users/Admin@orderer.com/msp/config.yaml"
}

function clearEverything() {
  sudo rm -rf organizations/fabric-ca/ordererOrg
  sudo rm -rf organizations/fabric-ca/manufacturerOrg
  sudo rm -rf organizations/fabric-ca/retailerOrg
  sudo rm -rf organizations/fabric-ca/customerOrg

  rm -rf organizations/ordererOrganizations
  rm -rf organizations/peerOrganizations
}

createOrderer
createManufacturer
createRetailer
createCustomer

./organizations/ccp-generate.sh

#clearEverything