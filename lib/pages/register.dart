import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mis_libros/models/user.dart';
import 'package:mis_libros/pages/login.dart';
import 'package:mis_libros/repository/firebase_api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum Genre { masculino, famenino }

class _RegisterPageState extends State<RegisterPage> {

  final FirebaseApi _firebaseApi= FirebaseApi();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _respassword = TextEditingController();

  Genre? _genre = Genre.masculino;
  String _data = "informacion: ";


  String buttonMsg = "Fecha de nacimiento";
  String _date = "";

  String _dateConverter(DateTime newDate) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String dateFormtted = formatter.format(newDate);
    return dateFormtted;
  }

  void _showSelectDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      locale: const Locale("es", "CO"),
      initialDate: DateTime(2022, 8),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2022, 12),
      helpText: "Fecha de nacimiento",
    );
    if (newDate != null) {
      setState(() {
        _date = _dateConverter(newDate);
        buttonMsg = "Fecha de Nacimiento: ${_date.toString()}";
      });
    }
  }

  void _showMsg(String msg){
    final scaffold =ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(msg),
        action: SnackBarAction(
          label: 'Aceptar', onPressed: scaffold.hideCurrentSnackBar),
        ),
    );
  }

  void _saveUser(User user) async {
    var result = await _firebaseApi.crateUser(user);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));

  }

  void _registerUser(User user) async {
    //final SharedPreferences prefs= await SharedPreferences.getInstance();
    //await prefs.setString("user" , jsonEncode(user));

    var result = await _firebaseApi.registerUser(user.email, user.password);
    String msg  ="";
    if (result=="invalid-email"){msg="el correo electronico esta mal escrito ";}
    else if (result=="weak-password"){msg="la contraseña debe tener minimo 6 digitos";}
    else if (result=="email-already-in-use"){msg="Ya existe una cuenta con ese correo electronico";}
    else if (result=="network-request-failed"){msg="Revise su conexion a internet";}
    else {msg="Usuario registrado con exito";
      user.uid=result;
      _saveUser(user);
    }
    _showMsg(msg);


  }

  void _onRegisterButtonClicked() {
    setState(() {
      if (_password.text == _respassword.text) {
        String genre = "Masculino";
        String favoritos = "";

        if (_genre == Genre.famenino) {
          genre = "femenino";
        }

        var user = User("",
            _name.text, _email.text, _password.text, genre, _date);
        _registerUser(user);
      } else {
        _showMsg("las contraseñas deben de ser iguales");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Image(image: AssetImage('assets/images/logo.png')),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Nombre'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo Electronico'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Contrasena'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _respassword,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Repita Contrasena'),
                  keyboardType: TextInputType.text,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('masculino'),
                        leading: Radio<Genre>(
                          value: Genre.masculino,
                          groupValue: _genre,
                          onChanged: (Genre? value) {
                            setState(() {
                              _genre = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('femenino'),
                        leading: Radio<Genre>(
                          value: Genre.famenino,
                          groupValue: _genre,
                          onChanged: (Genre? value) {
                            setState(() {
                              _genre = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    _showSelectDate();
                  },
                  child: Text(buttonMsg),
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    _onRegisterButtonClicked();
                  },
                  child: const Text("Registrar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
