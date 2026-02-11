import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:opentak_app/pages/register.dart';
import 'package:opentak_app/Utils/_web.dart';
import 'package:opentak_app/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/db/app_database.dart';
import 'package:opentak_app/main.dart';
import 'package:opentak_app/Utils/_mqtt.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login({required String username, required String password, String? url}) async {
    try {
      final client = context.read<OpenTAKHTTPClient>();

      String serverUrl = await context.read<AppDatabase>().getServerUrl() ?? "";
      String inputUrl = url?.isNotEmpty == true ? url! : serverUrl;
      if (!mounted) return;

      final db = context.read<AppDatabase>();
      if (inputUrl.isEmpty) {
        inputUrl = "tak.kaktusgame.eu"; // Default server URL
      }

      final host = OpenTAKHTTPClient.normalizeHost(inputUrl);


      final savedHost = OpenTAKHTTPClient.normalizeHost(serverUrl);

      if (host != savedHost) {
        await db.insertOrUpdateUserSettings(serverUrl: host, username: username, email: null);
        client.setUrl(host);
      }


      String? token = await client.login(username, password);
      if (token != null) {
        // Login successful, navigate to home page
        // You can also save the token for future authenticated requests
        // Save token to database 
        await db.insertOrUpdateUserSettings(authToken: token, username: username, email: null);
        await db.setOnBoarded(true);
        // Set MQTT client with new token
        final mqttClient = OpenTAKMQTTClient();
        final mqttInfo = await Helper.getMQTTBrokerTokenAndUsername(db: db);
        String mqttUrl = mqttInfo[0];
        String mqttToken = mqttInfo[1];
        String mqttUsername = mqttInfo[2];
        String? deviceId = await Helper.getId();
        client.setAuthToken(token);
        await mqttClient.connect(brokerHost: mqttUrl, password: mqttToken, clientId: '$mqttUsername-$deviceId');
        
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Login failed, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please check your credentials and try again.')),
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
  String? serverUrl = '';
  bool passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
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
                      padding: const EdgeInsets.only(top: 20.0),
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
                        controller: _usernameController,
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
                        obscureText: !passwordVisible,
                        controller: _passwordController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter your password'),
                          MinLengthValidator(6,
                              errorText: 'Password must be at least 6 characters long'),
                        ]).call,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(
                                  () {
                                    passwordVisible = !passwordVisible;
                                  },
                                );
                              },
                            ),
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
                      onChanged: (value) {
                        serverUrl = value;
                      },
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
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              _login(username: _usernameController.text, password: _passwordController.text, url: serverUrl);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                    )),
                    Center(
                      child: Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                        Text(
                          'Or if you don\'t have an account',
                          style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                          // Navigate to register page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Register()),
                          );
                          },
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          ),
                          child: Text(
                          'Register',
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