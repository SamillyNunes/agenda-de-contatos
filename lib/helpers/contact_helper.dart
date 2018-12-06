import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';


final String contactTable = "contactTable"; //nome da tabela
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper{ //classe que nao vai poder ter varias instancias, e por isso o padrao singleton, so um objeto instanciado pra todos
  
  static final ContactHelper _instance = ContactHelper.internal();

  factory  ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async{
    if(_db!=null){
      return _db;
    } else { //caso o banco ainda nao tenha sido criado
      _db=await initDb();
      return _db;
    }

  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath(); //pega o caminho do bd
    final path = join(databasePath,"contactsnew.db"); //pega o arquivo do bd LEMBRAR DE MUDAR O NOME SE FOR PRECISO

    return await openDatabase(path,version:1,onCreate: (Database db, int newerVersion) async{
      await db.execute( //executar um cod responsavel por criar a tabela de dados
        //comandos em letra maiuscula e parametros em letra minuscula
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,$nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)" //cria a tabela com os parametros e seus tipos
      );
    }); //passa o caminho, a versao e um funcao que vai ser usada ao criar o bd pela 1 vez
  }

  Future<Contact> saveContact(Contact contact) async { //salvar um contato num bancp
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap()); //ao salvar ele retorna o id
    return contact;
  }

  Future<Contact> getContact(int id) async { //pega os contatos
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,  //query eh uma forma de obter os dados que se quer
      columns: [idColumn,nameColumn,emailColumn,phoneColumn,imgColumn],
      where: "$idColumn=?", //regra para obter o contato, interrogacao pq passa o argumento no whereargs
      whereArgs: [id]
    );

    if(maps.length>0){
      return Contact.fromMap(maps.first); //retorna o primeiro elemento
    } else {
      return null;
    }

  }

  Future<int> deleteContact(int id) async { //deletar um contato
    Database dbContact = await db;
    return await dbContact.delete(contactTable,where: "$idColumn=?",whereArgs: [id]); //await pq ele nao deleta instantaneamente
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, 
      contact.toMap(), 
      where: "$idColumn=?", 
      whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable"); //raw query eh para fazer o select, se nao especifica o tipo da lista ele considera o tipo dinamico
    List<Contact> listContact = List();

    for (Map m in listMap){ //pra cada mapa ele transforma numa lista de contatos
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int> getNumber() async { //retorna a quantidade dos contatos
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable")); //OBTENDO A QUANTIDADE DE CONTATOS
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

//id name email phone img

class Contact{
  int id;
  String name;
  String email;
  String phone;
  String img; //nao da pra armazenar a img, entao se pega o local onde ela foi armazenada
  
  Contact();

  Contact.fromMap(Map map){ //quando formos armazenar sera no formato de mapa, logo precisa converter
    id=map[idColumn];
    name=map[nameColumn];
    email=map[emailColumn];
    phone=map[phoneColumn];
    img=map[imgColumn];
  }

  Map toMap(){ //conversao para mapa
    Map<String,dynamic> map = {
      nameColumn:name,
      emailColumn:email,
      phoneColumn:phone,
      imgColumn:img
    };

    if(id!=null){ //se o id n for nulo pq sera dado pelo bd
      map[idColumn]=id;
    }
    return map;
  }

  @override
  String toString(){
    return "Contact{id:$id, name:$name, email:$email, phone:$phone, img:$img}";
  }

}