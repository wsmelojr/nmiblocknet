##########################################################################
# INTER-NMI BLOCKCHAIN NETWORK EXPERIMENT - CHANNEL CONFIG - July/2020
# This script requires a pre configured docker environment, with the 
# peers and orderer associated with the respective org already started.
# It uses peer0 for creating a channel (when requested) and joins peer0 
# to the channel. After, it fetches by the channel with the other peers
# and also joins each peer to the channel.
# Author: Wilson S. Melo Jr.
##########################################################################
#!/bin/bash

# Remember to configure these auxiliar vars. They must reflect any name change
# when necessary.
ORDERER=orderer.nmi:7050
CHANNEL=nmi-channel
MSPCONFIGPATH=/etc/hyperledger/admsp
CAFILE=/etc/hyperledger/tlscacerts/tlsca.orderer.nmi-cert.pem

# Exit on first error.
set -e

#tests if the user informed $1 parameter 
if [ -z "$1" ]
    then
        echo "Usage "$0" <domain-name> [-c]"
        echo "  where <domain-name> is your organization name, and"
        echo "        -c is optional and indicates you are creating the channel."
        exit 2
fi

#set domain according to the informed parameter
DOMAIN=$1

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# starting config, creates a var to refer the active peer 
ACTPEER=peer0

#tests if the user informed $2 parameter 
if [ -z "$2" ]
    then
        #parameter not informed, the channel already exists and I do the fetch
        echo "---> FETCH CHANNEL with "$ACTPEER"."$DOMAIN
        docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel fetch 0 ${CHANNEL}_0.block  -o $ORDERER -c $CHANNEL --tls --cafile $CAFILE
        echo "---> JOIN CHANNEL with "$ACTPEER"."$DOMAIN
        docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel join -b ${CHANNEL}_0.block --tls --cafile $CAFILE

        #we need update anchors peers immediatly after creating the channel, and before to join other peers.
        echo "---> UPDATE CHANNEL with $DOMAIN anchors"
        docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH peer0.$DOMAIN peer channel update -o $ORDERER -c $CHANNEL -f /etc/hyperledger/configtx/$DOMAIN-anchors.tx --tls --cafile $CAFILE
    else
        if [[ "$2" == "-c" ]]
        then
            #parameter -c not informed, the channel MUST to be created
            echo "---> CREATE CHANNEL with "$ACTPEER"."$DOMAIN
            docker exec $ACTPEER.$DOMAIN peer channel create -o $ORDERER -c $CHANNEL -f /etc/hyperledger/configtx/$CHANNEL.tx --tls --cafile $CAFILE
            echo "---> JOIN CHANNEL with "$ACTPEER"."$DOMAIN
            docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel join -b ${CHANNEL}.block --tls --cafile $CAFILE

            #we need update anchors peers immediatly after creating the channel, and before to join other peers.
            echo "---> UPDATE CHANNEL with $DOMAIN anchors"
            docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH peer0.$DOMAIN peer channel update -o $ORDERER -c $CHANNEL -f /etc/hyperledger/configtx/$DOMAIN-anchors.tx --tls --cafile $CAFILE
        else
            echo "Usage "$0" <domain-name> [-c]"
            echo "  where <domain-name> is your organization name, and"
            echo "        -c is optional and indicates you are creating the channel."
            exit 2
    fi       
fi

#performs fetch & join for the other peers...
ACTPEER=peer1 #sets the active peer
echo "---> FETCH CHANNEL with "$ACTPEER"."$DOMAIN
docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel fetch 0 ${CHANNEL}_0.block -o $ORDERER -c $CHANNEL --tls --cafile $CAFILE
echo "---> JOIN CHANNEL with "$ACTPEER"."$DOMAIN
docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel join -b ${CHANNEL}_0.block

#if you have more peers, you can also add the call of the fetch/join commands to them below
# ACTPEER=MYNEWPEER #sets the active peer
# echo "---> FETCH CHANNEL with "$ACTPEER"."$DOMAIN
# docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel fetch config -o $ORDERER -c $CHANNEL --tls --cafile $CAFILE
# echo "---> JOIN CHANNEL with "$ACTPEER"."$DOMAIN
# docker exec -e CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH $ACTPEER.$DOMAIN peer channel join -b ${CHANNEL}_config.block
