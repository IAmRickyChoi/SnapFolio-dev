import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapfolio/domain/repositories/auth_repository.dart';
import 'package:snapfolio/domain/repositories/contact_repository.dart';
import 'package:snapfolio/presentation/pages/contact_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final contactRepository = context.read<ContactRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapFolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authRepository.signOut();
            },
          ),
        ],
      ),
      body: ContactListPage(repository: contactRepository),
    );
  }
}
