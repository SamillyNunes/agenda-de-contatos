import 'dart:io';

import 'package:contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact; //vai servir para pegar os dados do contato quando quiser editar, mas tbm para criar, entao o parametro eh opcional

  ContactPage({this.contact}); //param opcional

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode(); //focus eh para colocar o foco em um atributo

  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if(widget.contact ==null){ //widget.contact para pegar o atributo da classe acima
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap()); //duplicando o contato que foi enviado pra ca e convertendo o mapa dele p contatp

      //para o caso de edicao, ele ja vai jogar os dados nos campos
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //chama uma funcao minha quando eu clicar no botao de voltar na tela 
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title:Text(_editedContact.name ?? "Novo contato"), // ?? p o caso de nulos
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact.name!=null && _editedContact.name.isNotEmpty){
              Navigator.pop(context,_editedContact); //o pop remove a tela e volta pra anterior (esquema de pilha)
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container( //container em forma de ciculo para colocar a img
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage( //verifica se a imagem foi adicionada, se sim pega ela, senao pega a padrao
                      image: _editedContact.img!=null ? 
                        FileImage(File(_editedContact.img)) : 
                          AssetImage("images/person.png")
                    ),
                  ),
                ),
                onTap: (){
                  _showOptionsImg(context);
                  
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited=true; //para indicar que modificou algo no formulario e depois usar p a caixa de dialogo
                  setState(() {
                    _editedContact.name=text;                  
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited=true; //para indicar que modificou algo no formulario e depois usar p a caixa de dialogo
                  _editedContact.email=text;
                },
                keyboardType: TextInputType.emailAddress, //tipo do teclado p de email
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text){
                  _userEdited=true; //para indicar que modificou algo no formulario e depois usar p a caixa de dialogo
                  _editedContact.phone=text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog( //caixa de alerta
        context: context,
        builder: (context){
          return AlertDialog(
            title:Text("Descartar alterações?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context); //remove a tela do dialogo
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context); //remove a tela de dialogo
                  Navigator.pop(context); //remove a tela dos contatos
                },
              ),
            ],
          );
        },
      );
      return Future.value(false); //nao deixar sair automaticamente
    } else {
      return Future.value(true); //deixar sair automaticamente
    }
  }

  void _showOptionsImg(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  IconButton(
                    icon: Icon(Icons.camera,size: 30.0,),
                    
                    tooltip: "Camêra",
                    onPressed: (){
                      ImagePicker.pickImage( //abrir a camera
                        source: ImageSource.camera).then((file){
                          if(file==null) return;
                          setState(() {
                            _editedContact.img=file.path;                        
                          });
                        }
                        );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_album,size: 30.0),
                    tooltip: "Galeria",
                    onPressed: (){
                      ImagePicker.pickImage(
                        source: ImageSource.gallery).then((file){
                          if(file==null) return;
                          setState(() {
                            _editedContact.img=file.path;                        
                          });
                        });
                    },
                  ),
                ],
              )
            );
          },
        );
      }
    );
  }

}