import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/auth_pages/login_page.dart';
import 'package:graduation_progect_v2/pages/auth_pages/register_page.dart';


class LogRegAuthentication extends StatefulWidget {
  const LogRegAuthentication({super.key});

  @override
  State<LogRegAuthentication> createState() => _LogRegAuthenticationState();
}

class _LogRegAuthenticationState extends State<LogRegAuthentication> {
  bool showLoginPage = true;
  
  // i can do a toggel class // <---
  
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        loginPageTap: togglePage,
      );
    } else {
      return RegisterPage(
        registerPageTap: togglePage,
      );
    }
  }
}
