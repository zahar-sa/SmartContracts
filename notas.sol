// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental  ABIEncoderV2;

//----------------------------
//  ALUMNO /    ID    /  NOTA
//----------------------------
// Marcos  / 77755N   /   5
// Joan    / 12345N   /   9
// Maria   / 02468T   /   2
// Marta   / 13579U   /   3
// Alba    / 98765Z   /   5


contract notas{
    //Direccion del profesior
    address public profesor;

    //Constructor
    constructor() public {
        profesor = msg.sender;

    }
    //Mapping para relacionar el hash de la identidad del alumno con su nota del examen
    mapping(bytes32 => uint32) Notas;

    //Array de los alumnos que piden revision de examen
    mapping(string => string[]) revision;
    //string[] revision;

    //Eventos
    event alumno_evaluado(string,bytes32,uint32);
    event evento_revision(string);

    modifier unicamenteProfesor(address _direccion){
        require (profesor == _direccion,"No tienes permisos para ejecutar esta funcion");
        _;
    }

    //Funcion para evaluar a alumno
    function Evaluar (string memory _asignatura,string memory _idAlumno, uint32 _nota)public unicamenteProfesor(msg.sender) returns(uint32){
        //hash de la identificacion del alumno
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_asignatura,_idAlumno));
        //Relacion entre el hash del la identificacion del alumno y su nota
        Notas[hash_idAlumno] = _nota;
        //Emision del evento
        emit alumno_evaluado(_asignatura,hash_idAlumno,_nota);
        return _nota;

    }
    //ver notas del alumno
    function VerNotas (string memory _asignatura,string memory _idAlumno) public view returns(uint32){
        //hash de la identificacion del alumno
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_asignatura,_idAlumno));
        //Nota asociada al hash del alumno
        uint32 nota_alumno = Notas[hash_idAlumno];
        //visualizar la nota
        return nota_alumno;
    }

    //solicitar Revision
    function Revision(string memory _asignatura,string memory _idAlumno)  public{
        //Almacenamiento de la identidad del alumno en un arreglo
        //revision.push(_idAlumno);
        revision[_asignatura].push(_idAlumno);
        emit evento_revision(_idAlumno);

    }

    function Lista_revision(string memory _asignatura) public unicamenteProfesor(msg.sender) view returns(string[] memory){
        return revision[_asignatura];

    }

}
