//SPDX-License-Identifier: GPL - 3.0
pragma solidity >0.4.0 <0.7.0;

contract  fondeo{
    enum  Estado {init,opened,closed}

    struct  fonStruct{   
        string  nombre;
        string  proyecto;
        Estado  status;
        uint    capital;
        address payable  owner;
        uint    metaMonetaria;
    }
   
    


    modifier onlyOwner(){
        require(proyecto.owner == msg.sender,"Only Owner can change something ");
        _;
    }

    modifier noOwner(){
        require(proyecto.owner != msg.sender,"no Owner can add founds ");
        _;
    }
    event fundProjectData(
        address contribuyente,
        uint cooperacion,
        uint montoActual
    );
    event changeProyectState(
        Estado estadoactual
    );
fonStruct public proyecto;
    constructor () public   {
     /*  nombre = "Generico";
       proyecto = "Generico";
       status = "StandBy";
       capital = 0;
       owner = payable(msg.sender);
       metaMonetaria = 1 ether;*/
       proyecto = fonStruct("Generico","Generico",Estado.init,0,msg.sender,1 ether);

    }
    function setUpProyect(string memory _nombre, string memory _proyecto, Estado _status)public {
        proyecto.nombre = _nombre;
        proyecto.proyecto = _proyecto;
        proyecto.status = _status;

    }

    

//un autor no puede financiar su propio proyecto
    function fundProject(address payable _direccionATransferir) public payable  noOwner returns(Estado,uint){
        require(msg.value != 0, "Deben agregarse valores mayores a cero");
        require(proyecto.capital <= proyecto.metaMonetaria, "se ha llegado a la meta, no se permiten mas fondeos");
        _direccionATransferir.transfer(msg.value);
        proyecto.capital +=   msg.value;
        emit fundProjectData(_direccionATransferir,msg.value,proyecto.capital);
        if (proyecto.capital <= 1 ether){
            changeProjectState(Estado.opened);
        }
            
        else {
            changeProjectState(Estado.closed);
        }   
            
        
        return (proyecto.status,proyecto.capital);
    }

    function changeProjectState( Estado _status) private {

        proyecto.status=_status;
        emit changeProyectState(_status);

    }

}