#!/bin/bash

# Delete existing artifacts
rm ../system-genesis-block/genesis.block
rm -rf ../channel-artifacts/*

# System channel
SYS_CHANNEL="sys-channel"

CHANNEL_NAME="supply-chain"

echo $CHANNEL_NAME

CONFIG_PATH="../configtx/"

#For .tx files The channel creation transaction specifies the initial configuration of the channel and is used by
# the ordering service to write the channel genesis block.

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath $CONFIG_PATH -channelID $SYS_CHANNEL -outputBlock ../system-genesis-block/genesis.block

# Generate channel configuration block
configtxgen -profile BasicChannel -configPath $CONFIG_PATH -outputCreateChannelTx ../channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for ManufacturerMSP  ##########"
configtxgen -profile BasicChannel -configPath $CONFIG_PATH -outputAnchorPeersUpdate ../channel-artifacts/ManufacturerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ManufacturerMSP

echo "#######    Generating anchor peer update for RetailerMSP  ##########"
configtxgen -profile BasicChannel -configPath $CONFIG_PATH -outputAnchorPeersUpdate ../channel-artifacts/RetailerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg RetailerMSP

echo "#######    Generating anchor peer update for CustomerMSP  ##########"
configtxgen -profile BasicChannel -configPath $CONFIG_PATH -outputAnchorPeersUpdate ../channel-artifacts/CustomerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg CustomerMSP