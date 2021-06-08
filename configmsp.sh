##########################################################################
# INTER-NMI BLOCKCHAIN NETWORK EXPERIMENT - MSP CONFIG - July/2020
# This script generates the nmiblocknet MSP structure (cryptographic keys 
# and certificates). All these stuffs are created in a directory called
# crypto-config. The script also generates the network genesis block, the
# nmi-channel profile and the anchors profile to update the channel after
# its creation. The script consumes the configurations in the files 
# crypto-config-nmi.yaml and configtx.yaml.
# Author: Wilson S. Melo Jr. - Inmetro
##########################################################################
#/bin/bash
export FABRIC_CFG_PATH=$PWD

cd "$(dirname "$0")"

# generates MSP artefacts (keys, digital certificates, etc) in the folder ./crypto-config
cryptogen extend --config=./crypto-config-nmi.yaml

# creates the genesis block
configtxgen -profile NMIGenesis -outputBlock ./nmi-genesis.block

# creates the channel config file 
configtxgen -profile NMIChannel -outputCreateChannelTx ./nmi-channel.tx -channelID nmi-channel

# creates anchors config for each organization (PTB and Inmetro, so far)
configtxgen -profile NMIChannel -outputAnchorPeersUpdate ptb.de-anchors.tx -channelID nmi-channel -asOrg PTB
configtxgen -profile NMIChannel -outputAnchorPeersUpdate inmetro.br-anchors.tx -channelID nmi-channel -asOrg Inmetro