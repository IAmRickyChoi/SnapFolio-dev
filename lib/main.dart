import 'package:flutter/material.dart';
import 'data/repositories/contact_repository_impl.dart';
import 'presentation/pages/contact_list_page.dart';

void main() {
  runApp(const SnapFolioApp());
}

class SnapFolioApp extends StatelessWidget {
  const SnapFolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 의존성 주입 (Dependency Injection) - 수동 버전
    // 나중엔 Riverpod provider가 이 역할을 대신함.
    final contactRepository = ContactRepositoryImpl();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapFolio',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 레포지토리를 페이지에 꽂아 넣어줌
      home: ContactListPage(repository: contactRepository),
    );
  }
}