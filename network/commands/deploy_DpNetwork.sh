#!/bin/bash

# Copyright Tecnalia Research & Innovation (https://www.tecnalia.com)
# Copyright Tecnalia Blockchain LAB
#
# SPDX-License-Identifier: Apache-2.0

#BASH CONFIGURATION
# Enable colored log
export TERM=xterm-256color


PEER0_PROVIDER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/provider.policiamilitar.sp.gov.br/peers/peer0.provider.policiamilitar.sp.gov.br/tls/ca.crt 

#CONSUMER
PEER0_CONSUMER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/consumer.policiamilitar.sp.gov.br/peers/peer0.consumer.policiamilitar.sp.gov.br/tls/ca.crt

#ORDERER
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/policiamilitar.sp.gov.br/orderers/orderer.policiamilitar.sp.gov.br/msp/tlscacerts/tlsca.policiamilitar.sp.gov.br-cert.pem


setGlobals() {
  ORG=$1
  PEER=$2
  
  echo "------>   "$ORG
  echo "------>   "$PEER
  

  if [ $ORG -eq 1 ]; then
    echo "PROVIDER..."
	CORE_PEER_LOCALMSPID="ProviderMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/provider.policiamilitar.sp.gov.br/peers/peer0.provider.policiamilitar.sp.gov.br/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/provider.policiamilitar.sp.gov.br/users/Admin\@provider.policiamilitar.sp.gov.br/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.provider.policiamilitar.sp.gov.br:7051
    else
      CORE_PEER_ADDRESS=peer1.provider.policiamilitar.sp.gov.br:7051
    fi
  elif [ $ORG -eq 2 ]; then
	echo "CONSUMER..."
    CORE_PEER_LOCALMSPID="ConsumerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/consumer.policiamilitar.sp.gov.br/peers/peer0.consumer.policiamilitar.sp.gov.br/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/consumer.policiamilitar.sp.gov.br/users/Admin@consumer.policiamilitar.sp.gov.br/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.consumer.policiamilitar.sp.gov.br:7051
    else
      CORE_PEER_ADDRESS=peer1.consumer.policiamilitar.sp.gov.br:7051
    fi

  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="Org3MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org3.example.com:11051
    else
      CORE_PEER_ADDRESS=peer1.org3.example.com:12051
    fi
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}


function banner(){
	echo ""
	echo "   ____        ______  "
	echo " |   _   \   /  _____| "
	echo " |  | |  |  |  | "
	echo " |   _  /   |  | "
	echo " |  | |  |  |  |_____"
	echo " |__| |_ |   \_______|"
	echo ""
	echo ""
	echo ""
}


function createChannel(){
    echo "#### 15s"
	sleep 15 

	setGlobals 1 0

    peer channel create -o orderer.policiamilitar.sp.gov.br:7050 -c channeldp -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/policiamilitar.sp.gov.br/orderers/orderer.policiamilitar.sp.gov.br/msp/tlscacerts/tlsca.policiamilitar.sp.gov.br-cert.pem
	
	echo ""
	echo "CANAL CRIADO!"
	echo ""
	echo ""

    exportProvider
	
}

function exportProvider(){
	
	echo "Criando Variaveis de Ambiente do PROVIDER!!"

    
	echo "#"
    sleep 1s
    
	while ! [ -f ./channeldp.block ];
	do
		echo "#"
		sleep 1
	done
	
	peer channel join -b channeldp.block 
    
	echo "JOIN PROVIDER PEER 0"
    sleep 1s

	
	setGlobals 1 1
		
	while ! [ -f ./channeldp.block ];
	do
		echo "#"
		sleep 1
	done


    peer channel join -b channeldp.block 
     echo "JOIN PROVIDER PEER 1"
    sleep 1s

	exportConsumer

}

function exportConsumer(){
	
	setGlobals 2 0

	echo "Criando Variaveis de Ambiente do CONSUMER!!"

	echo "#"
    sleep 1s
    
	while ! [ -f ./channeldp.block ];
	do
		echo "#"
		sleep 1
	done
	
	peer channel join -b channeldp.block 
    
	echo "JOIN CONSUMER PEER 0"
    sleep 1s

    setGlobals 2 1
	
	while ! [ -f ./channeldp.block ];
	do
		echo "#"
		sleep 1
	done

    peer channel join -b channeldp.block 
     echo "JOIN CONSUMER PEER 1"
    sleep 1s

	updateProvider
}

function updateProvider(){

	echo "UPDATE PROVIDER"

	setGlobals 1 0

	peer channel update -o orderer.policiamilitar.sp.gov.br:7050 -c channeldp -f ./channel-artifacts/ProviderMSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/policiamilitar.sp.gov.br/orderers/orderer.policiamilitar.sp.gov.br/msp/tlscacerts/tlsca.policiamilitar.sp.gov.br-cert.pem

	updateConsumer

}

function updateConsumer(){

	echo "UPDATE CONSUMER"

	setGlobals 2 0

	peer channel update -o orderer.policiamilitar.sp.gov.br:7050 -c channeldp -f ./channel-artifacts/ConsumerMSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/policiamilitar.sp.gov.br/orderers/orderer.policiamilitar.sp.gov.br/msp/tlscacerts/tlsca.policiamilitar.sp.gov.br-cert.pem

	installChaincodeProvider
}

function installChaincodeProvider(){

	echo "INSTALL CHAINCODE PROVIDER - PEER 0"

	setGlobals 1 0

	peer chaincode install -n controlediario -v 1.0.3 -l node -p /opt/gopath/src/github.com/chaincode/controlediario

	echo "INSTALL CHAINCODE PROVIDER - PEER 1"

	setGlobals 1 1

	peer chaincode install -n controlediario -v 1.0.3 -l node -p /opt/gopath/src/github.com/chaincode/controlediario

	installChaincodeConsumer

}

function installChaincodeConsumer(){

	echo "INSTALL CHAINCODE CONSUMER - PEER 0"

	setGlobals 2 0

	peer chaincode install -n controlediario -v 1.0.3 -l node -p /opt/gopath/src/github.com/chaincode/controlediario

	echo "INSTALL CHAINCODE CONSUMER - PEER 1"

	setGlobals 2 1

	peer chaincode install -n controlediario -v 1.0.3 -l node -p /opt/gopath/src/github.com/chaincode/controlediario

	peer chaincode list --installed

	instanceChaincodeProvider

}

function instanceChaincodeProvider(){

	echo "INSTANTIANTING CHAINCODE PROVIDER"

	setGlobals 1 0

	peer chaincode instantiate -o orderer.policiamilitar.sp.gov.br:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/policiamilitar.sp.gov.br/orderers/orderer.policiamilitar.sp.gov.br/msp/tlscacerts/tlsca.policiamilitar.sp.gov.br-cert.pem -C channeldp -n controlediario -v 1.0.3 -l node -c '{"Args":[]}' -P "OR ('ProviderMSP.peer','ConsumerMSP.peer')"

	peer chaincode list --instantiated -C channeldp

	res=$?
	
	verifyResult $res

	invokeChaincodeProvider
}

function queryChaincodeProvider(){

	echo "QUERING CHAINCODE PROVIDER"

	setGlobals 1 0

	peer chaincode query -n controlediario -c '{"Args":["31091284890"], "Function":"getPessoa"}' -C channeldp

	res=$?
	
	verifyResult $res

}

function invokeChaincodeProvider(){

	echo "INVOKE CHAINCODE PROVIDER"
	
	setGlobals 2 1
	echo "#"
	sleep 
	echo "#"
	sleep 1
	echo "#"
	sleep 1
	echo "#"
	sleep 1
	echo "#"
	sleep 1

	peer chaincode invoke -o orderer.policiamilitar.sp.gov.br:7050  --tls true --cafile $ORDERER_CA -C channeldp -n controlediario -c '{"Args":["31091284890", "RODRIGO CARDOSO", "PMESP", "DP", "SETOR", "DESENV WEB", "CHEFE", "ARQUITETO DE SOFTWARES", "9:00", "18:00", "01/01/2020", "01/01/2020", "ATIVO", "TRUE", "1234556789", "TRUE", "987654321", "VALIDADO" ], "Function":"registrarDia"}'

	res=$?
	
	verifyResult $res

	echo
	echo " _____   _   _   ____   "
	echo "| ____| | \ | | |  _ \  "
	echo "|  _|   |  \| | | | | | "
	echo "| |___  | |\  | | |_| | "
	echo "|_____| |_| \_| |____/  "
	echo
}

function deploy_run_explorer(){
	stop_explorer

	echo "Deploying Hyperledger Fabric Explorer no container $explorer_ip"
	docker run \
		-d \
		--name $fabric_explorer_name \
		--net $docker_network_name --ip $explorer_ip \
		-e DATABASE_HOST=$db_ip \
		-e DATABASE_USERNAME=$explorer_db_user \
		-e DATABASE_PASSWD=$explorer_db_pwd \
		-v $network_config_file:/opt/explorer/app/platform/fabric/config.json \
		-v $network_crypto_base_path:/tmp/crypto \
		-p 8080:8080 \
		hyperledger-blockchain-explorer
}

function main(){
	banner
    #Pass arguments to function exactly as-is
    config "$@"

	MODE=$1;
    if [ "$MODE" == "--down" ]; then
	    echo "Parando...."
    elif [ "$MODE" == "--clean" ]; then
	    echo "Limpando...."
        #stop_explorer
        #stop_database
        #docker rmi $(docker images -q ${fabric_explorer_db_tag}) -f
        #docker rmi $(docker images -q ${fabric_explorer_tag}) -f
    else
        echo "Subindo...."
        createChannel
        #deploy "$@"
    fi
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FALHOU ==========="
    echo
    exit 1
  fi
}

#Pass arguments to function exactly as-is
main "$@"