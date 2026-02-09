import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapfolio/domain/entities/user_entity.dart';
import 'package:snapfolio/presentation/pages/home_page.dart';
import 'package:snapfolio/presentation/pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserEntity?>(context);

    if (user == null) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
