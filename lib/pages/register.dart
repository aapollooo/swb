import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> register() async {
  final fullName = fullNameCtrl.text.trim();
  final email = emailCtrl.text.trim();
  final password = passwordCtrl.text.trim();

  if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
    showAlert("Validation Error", "All fields are required");
    return;
  }

  setState(() => isLoading = true);

  try {
    var url = Uri.parse("http://localhost/swb_api/register.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        showAlert(
          "Success",
          data['message'] ?? "Registered successfully!",
          isSuccess: true,
        );
      } else {
        showAlert(
          "Registration Failed",
          data['message'] ?? "Something went wrong",
        );
      }
    } else {
      showAlert("Server Error", "HTTP ${response.statusCode}");
    }
  } catch (e) {
    setState(() => isLoading = false);
    showAlert("Connection Error", e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fullNameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void showAlert(String title, String message, {bool isSuccess = false}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);

            if (isSuccess) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

}
