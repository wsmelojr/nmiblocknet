##########################################################################
# INTER-NMI BLOCKCHAIN NETWORK EXPERIMENT - CHAINCODE CONFIG - July/2020
# This script requires a pre configured docker environment, with the 
# peers and orderer associated with the respective org already started 
# and the respective channel configured.
# It uses the informed cli container to install|instantiate|upgrade the
# specific chaincode. The chaincode source code MUST be in the base
# directory of the nmiblocknet and have the same chaincode name. 
# The script implements Fabric Chaincode 1.4 Life Cicle. It does not work 
# for other Fabric versions.
# REMEMBER TO CHECK if the auxiliar vars are the same of the script.
# configurechannel.sh.
# Author: Wilson S. Melo Jr. - Inmetro
##########################################################################
#!/bin/bash

# *** VERY IMPORTANT *** 
# This script does not support chaincodes that require Args on the Init() method. 
# If it is your case, modify the script properly.

# Remember to configure these auxiliar vars. They must reflect any name change
# when necessary.
ORDERER=orderer.nmi:7050
CHANNEL=nmi-channel
MSPCONFIGPATH=/etc/hyperledger/admsp
CAFILE=/etc/hyperledger/tlscacerts/tlsca.orderer.nmi-cert.pem
CC_INTERNAL_PATH=github.com/hyperledger/fabric/peer/channel-artifacts

# Exit on first error.
set -e

#tests if the number of arguments
if [ "$#" -ne 4 ]; then
    # wrong parameters, notify the user
    echo "Usage: $0 install|instantiate|upgrade <CLI container> <chaincode name> <chaincode version>"
    echo "   e.g.> $0 install cli0 fabmorph 1.3"
    exit 2
fi

#translate the args into frindly vars
ACTION=$1
CLI=$2
CC_NAME=$3
CC_VERSION=$4

#treat the command according to the required action
case $ACTION in
	install)
        # The action is install chaincode: source code is compiled and installed in a peer
		echo "---> INSTALL CHAINCODE using $CLI: ($CC_NAME,$CC_VERSION)"
        docker exec $CLI peer chaincode $ACTION -n $CC_NAME -p $CC_INTERNAL_PATH/$CC_NAME -v $CC_VERSION --tls --cafile $CAFILE
        exit 0
        ;;
	instantiate)
        # The action is instantiate chaincode in the channel: the network accepts that the chaincode can be executed from now
		echo "---> INSTANTIATE CHAINCODE using $CLI: ($CC_NAME,$CC_VERSION)"
        docker exec $CLI peer chaincode $ACTION -o $ORDERER -C $CHANNEL -n $CC_NAME -v $CC_VERSION -c '{"Args":[]}' --tls --cafile $CAFILE
        exit 0
        ;;
	upgrade)
        # The action is upgrade chaincode in the channel: the network accepts a new version of a previously instantiated chaincode
		echo "---> UPGRADE CHAINCODE using $CLI: ($CC_NAME,$CC_VERSION)"
        docker exec $CLI peer chaincode $ACTION -o $ORDERER -C $CHANNEL -n $CC_NAME -v $CC_VERSION -c '{"Args":[]}' --tls --cafile $CAFILE
        exit 0
        ;;
esac

# if the script is still running, the request $ACTION is unknown...
echo "Usage: $0 install|instantiate|upgrade <CLI container> <chaincode name> <chaincode version>"
echo "   e.g.> $0 install cli0 fabmorph 1.3"
exit 2