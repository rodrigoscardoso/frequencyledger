
/*******************************************************************************
 * Copyright 2018 Rodrigo Morbach. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy
 * of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ******************************************************************************/



const shim = require('fabric-shim')

var ControleDiaChaincode = class {

    /**
     * Part of ChaincodeInterface. This method is called once when the chaincode is instantiated in the channel.
     * Can be used to perform an initial load on the ledger. 
     */
    async Init() {
        console.log('Iniciou!!!');
        return shim.success('Smart Contract foi instanciado!!');
    }

    /**
     * Part of ChaincodeInterface. This method is called for each transaction performed using this chaincode.
     */
    async Invoke(stub) {
        
        console.log('Invocado!!!!!')

        let ret = stub.getFunctionAndParameters();
        
        let creator = stub.getCreator();
        
        if (creator) {
            
            console.log(creator.mspid + ' Invocando...');
        
        }

        let methodToInvoke = this[ret.fcn];
        if (!methodToInvoke) {
            
            shim.error(new Error('O nome do método deve ser iniciado!!'));
        
        }

        try {
            
            let payload = await methodToInvoke(stub, ret.params);
            
            return shim.success(payload);
        
        } catch (e) {

            return shim.error(e);

        }

        
    }

    /**
     * Registers a product in the ledger. The product is a simple structure composed by an identifier, a name and a price.
     * @param {Object} stub provided by fabric-shim
     * @param {Array} args array of strings with product information, for example: ["productIdentifier", "product name", "product price"].
     * peer chaincode invoke -n deal -c '{"Args":["31091284890", "RODRIGO SANTOS CARDOSO", "DIRETORIA DE PESSOAL"], "Function":"registrarDia"}' -C channeldp
     */


    async registrarDia(stub, args) {
        if (args.length < 18) {
            throw new Error('Número de argumentos inválido!!!!')
        }

        let cpf = args[0];
        let nome = args[1];
        let orgao = args[2];
        let unidade = args[3];
        let tipoUO = args[4];
        let atribuicao = args[5];
        let funcao = args[6];
        let atividade = args[7];
        let horaEntrada = args[8];
        let horaSaida = args[9];
        let dataEntrada = args[10];
        let dataSaida = args[11];
        let situacaoAdm = args[12];
        let checkEscalante = args[13];
        let timeStampCheckEscalante = args[14];
        let checkSistema = args[15];
        let timeStampCheckSistema = args[16];
        let estado = args[17];
        

        let controleDiaObject = {
                nome: nome,
                orgao: orgao,
                unidade: unidade,
                tipoUO: tipoUO,
                atribuicao: atribuicao,
                funcao: funcao,
                atividade: atividade,
                horaEntrada: horaEntrada,
                horaSaida: horaSaida,
                dataEntrada: dataEntrada,
                dataSaida: dataSaida,
                situacaoAdm: situacaoAdm,
                checkEscalante: checkEscalante,
                timeStampCheckEscalante: timeStampCheckEscalante,
                checkSistema: checkSistema,
                timeStampCheckSistema: timeStampCheckSistema,
                estado: estado

        };

        await stub.putState(cpf, Buffer.from(JSON.stringify(controleDiaObject)));
    }

    /**
     * Query a product in the ledger using its identifier.
     * @param {Object} stub provided by fabric-shim,
     * @param {Array} args array of string with query parameters. In this case, only one argument is required. E.g, ["productIdentifier"].
     */
    async getPessoa(stub, args) {

        if (args.length < 1) {
            throw new Error('E necessario informar o CPF!!');
        }

        let cpfIdenty = args[0];

        var pessoaBytes = await stub.getState(cpfIdenty);
        
        if (!pessoaBytes || pessoaBytes.toString().length <= 0) {
            throw new Error('Pessoa com CPF ' + cpfIdenty + ' nao encontrada!!');
        }
        return pessoaBytes;
    }
}

let chaincode = new ControleDiaChaincode()

shim.start(chaincode)

