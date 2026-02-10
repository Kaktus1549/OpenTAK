import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:opentak_app/pages/login.dart';
import 'package:opentak_app/Utils/_web.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/db/app_database.dart';

class Register extends StatefulWidget {

  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  void _register({required String username, required String email, required String password, String? secretCode, String? url}) async {
    if (url == null || url.isEmpty) {
      url = 'tak.kaktusgame.eu';
    }
    try {
      final client = context.read<OpenTAKHTTPClient>();
      final host = OpenTAKHTTPClient.normalizeHost(url);
      client.setUrl(host);
      bool success = await client.register(username, email, password, secretCode);
      if (success) {
        // Registration successful, navigate to login page
        if (!mounted) return;
        
        final db = context.read<AppDatabase>();
        // Save user data to database
        await db.insertOrUpdateUserSettings(username: username, email: email, serverUrl: host);
        await db.setOnBoarded(true);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        // Registration failed, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User registration failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String secretCode = '';
  String url = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          height: 150,
                          child: Image.asset('assets/test/m.jpg'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        onChanged: (value) => username = value,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter your username'),
                          MinLengthValidator(3,
                              errorText: 'Minimum 3 characters required'),
                        ]).call,

                        decoration: InputDecoration(
                            hintText: 'Enter your username',
                            labelText: 'Username',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (value) => email = value,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter your email address'),
                          EmailValidator(
                              errorText: 'Please enter a valid email address'),
                        ]).call,
                        decoration: InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.lightBlue,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (value) => password = value,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter your password'),
                          MinLengthValidator(6,
                              errorText: 'Password must be at least 6 characters long'),
                        ]).call,
                        decoration: InputDecoration(
                            hintText: 'Enter your password',
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[600],
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                      initialValue: 'tak.kaktusgame.eu',
                      onChanged: (value) => url = value,
                      decoration: InputDecoration(
                        hintText: 'OpenTAK server domain',
                        labelText: 'OpenTAK server domain',
                        prefixIcon: Icon(
                          Icons.language,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius:
                            BorderRadius.all(Radius.circular(9)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (value) => secretCode = value,
                        decoration: InputDecoration(
                            hintText: 'Secret code (optional)',
                            labelText: 'Secret code',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)))),
                      ),
                    ),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              _register(username: username, email: email, password: password, secretCode: secretCode.isEmpty ? null : secretCode, url: url.isEmpty ? null : url);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                    )),
                    Center(
                      child: Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                        Text(
                          'Or if you already have an account',
                          style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                          // Navigate to login page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                          },
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          ),
                          child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          ),
                        ),
                        ],
                      ),
                      ),
                    )
                  ],
                )),
          ),
        ));
  }
}