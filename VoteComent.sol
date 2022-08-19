// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/*****************
   @title  Curso "Ethereum Developer Professional 2022"
   @author Nicolas Garcia
   @notice Sistema centralizado de votación,
           el administrador otorga permiso de voto
   @tarea  seleccionar por cantidades quien tiene permiso de voto 
 *****************/

//@dev tipo view = consulta el estado o datos de un contrato pero no modifica, no gasta gas
//@dev tipo pure = no consulta ningún dato, solo haces operación

//msg.sender-> es la persona que está desplegando el contrato y la que va a ser el administrador

//////////////////////// ParseString ///////////////////
contract ParseStrings{
    ///@dev pasa de string a bytes32. si la cadena es muy larga la corta    
    function stringToBytes32(string memory _text) external pure returns (bytes32){
        return bytes32(bytes(_text));
    }
    ///@dev la data que recibimos se va a empaquetar
    function bytes32ToString(bytes32 _data) external pure returns (string memory){
        return string(abi.encodePacked(_data));
    }
    //resultado de las funciones 
    // 0x53616e746961676f000000000000000000000000000000000000000000000000 - > Santiago
    // 0x5061626c6f000000000000000000000000000000000000000000000000000000 - > Pablo
}
/////////////////////////// CEVote /////////////////////////////
/// CEVote hereda funcionalidad de PerseString
contract CEOVote is ParseStrings{
 //storage
    struct Voter{
        bool voted;
        bool canVote;// es otro criterio para poder votar
        uint256 candidateIndex;//arreglo de candidatos
        uint256 weight; // si tiene un peso de 0 no puede votar 
    }

    struct Candidate{
        bytes32 name;
        uint256 voteCount;
    }

    mapping(address => Voter) public voters;

    address public admin;
    bool public isActive = true;//la votación esta activa desde el momento que se despliega
    uint256 public startDate = block.number;//estamos dependiendo de una variable global que puede cambiar un minero

    Candidate[2] public candidates;
 ///@dev eventos son logs que quiero tener en mi contrato al momento de aplicar 
 ///        Funcionalidad que cambie el estado, es decir , necesitamos tener un evento 
 ///        Para saber cuándo una persona votó  
 ///@dev indexed ayuda a filtrar de entre todos los eventos a un candidato determinado
    event Vote(bytes32 indexed _canditate);

 ///@dev  los modifier son condiciones para una función
 ///      quiero que una función solo sea ejecutado por el administrador que se define 
 ///      al momento de desplegar el contrato 
    modifier onlyAdmin{
        require(msg.sender == admin, "Only admin allow");
        _; //es para que continue la funcion del mofier una vez que termine la validación
    }
 /* @param en este constructor se pasaran los candidatos */
    constructor(bytes32 _candidateOne, bytes32 _candidateTwo){
        admin = msg.sender;
        candidates[0] = Candidate({
            name: _candidateOne,
            voteCount: 0
        });

        candidates[1] = Candidate({
            name: _candidateTwo,
            voteCount: 0
        });
    }

    function vote(uint256 _canditate) external{
        //calldata trae todas listas de datos de la transacción pero no se pueden modificar
        //memory  es un valor activo solo en momento de la ejecución, usualmente es para tipos dinamicos
        //storage escribe en blockchain, cuando necesito solo un valor de una variable o maping para modificarlo
        Voter storage sender = voters[msg.sender];
        require(sender.canVote, "You cannot participate");
        require(_canditate < 2, "Invalid vote");
        require(!sender.voted, "Already voted");
        ///////require(!sender.weight<1, "Already voted");///////
        sender.voted = true;
        sender.weight = 0;///////
        sender.candidateIndex = _canditate;

        candidates[_canditate].voteCount++;
        ///////11520---3dias
        if(candidates[_canditate].voteCount > 2 || block.number > startDate + 11520){
            finishVoting();
        }
    }

 ///@dev nos permite saber quién puede votar
 ///@dev esta función valida primero con un modifier
    function giveRightToVote(address _voter) external onlyAdmin{
     /* option 1
       if(msg.sender != admin){
            revert("CanNot call this function you are not admin")
        }
        option 2
        require(msg.send == admin, "CanNot call this function you are not admin")

     */   
        require(!voters[_voter].voted, "Already voted");
        ////////////////////////////////////////validación para weight
        //require(voters[_voter].weight>0,"Can voted")
        voters[_voter].canVote = true;
        ///////voters[_voter].weight = 1;///////
    }

 ///@notice determina fin de la votacion
    function finishVoting() internal{
        isActive = false;
    }
    ///////se quito la funcion winningCandidate() public view()

  ///@notice nombre del ganador
    function winningName() public view returns(bytes32){
        require(!isActive, "Still active");
        if(candidates[0].voteCount > candidates[1].voteCount){
            return candidates[0].name;
        }else{
            return candidates[1].name;
        }
    }
}

////////////////////////////////interface ICEVote////////////////////////////
interface ICEOVote{
    function winningName() external view returns(bytes32);
    function isActive() external view returns(bool);
}

////////////////////////////////CEOBet////////////////////////////

contract CEOBet{
    struct Gambler{
        bytes32 userBet;
        bool alreadyBet;
    }

    ICEOVote public target;/////// instancia

    mapping(address => Gambler) public gamblers;
    mapping(address => bool) public isWhitelisted;

    constructor(address one, address two, ICEOVote _target){
        target = _target;
        isWhitelisted[one] = true;///votante1
        isWhitelisted[two] = true;///votante2
    }

    function getStatus() public view returns(bool){
        return ICEOVote(target).isActive();
    } 

    function bet(bytes32 _candidate) public payable{
        bool isActive = getStatus();
        require(isActive, "Already finished");
        require(isWhitelisted[msg.sender], "You cannot participate");
        require(msg.value == 1 ether, "Must bet one ether");
        require(!gamblers[msg.sender].alreadyBet, "Already Bet");
        Gambler storage gambler = gamblers[msg.sender];
        gambler.alreadyBet = true;
        gambler.userBet = _candidate;
    }

    function claim() public{
        bool isActive = getStatus();
        require(!isActive, "Still Active");
        require(isWhitelisted[msg.sender], "You cannot participate");
        require(gamblers[msg.sender].userBet == ICEOVote(target).winningName(), "Is not the winner");
        ///@dev msg.sender.send  ---Deprecate  gasta mucho gas
        ///@devmsg.sender.trasfer ---Deprecate gasta mucho gas
        ///@dev se va a enviar al msg.sender todo lo que tenga el contrato, este contrato maximo tendra 2 ether
        ///@dev (bool success,) la funcion call regresa un booleano y un byte32 pero como no se necesita solo se deja en blanco
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transaction fail");
    }
}
