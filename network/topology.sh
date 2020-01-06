../bin/configtxgen -profile OrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
../bin/configtxgen -profile DPOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channeldp
../bin/configtxgen -profile DPOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/ProviderMSPanchors.tx -channelID channeldp -asOrg ProviderMSP
../bin/configtxgen -profile DPOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/ConsumerMSPanchors.tx -channelID channeldp -asOrg ConsumerMSP
