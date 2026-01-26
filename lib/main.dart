import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. 파이어베이스 코어 추가
import 'firebase_options.dart'; // 2. 설정 파일 가져오기

import 'data/repositories/contact_repository_impl.dart';
import 'presentation/pages/contact_list_page.dart';

// 3. main을 비동기(async) 함수로 변경
void main() async {
  // 4. 플러터 엔진과 네이티브(iOS/Android) 연결 (필수!)
  WidgetsFlutterBinding.ensureInitialized();

  // 5. 파이어베이스 시동 걸기
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SnapFolioApp());
}

class SnapFolioApp extends StatelessWidget {
  const SnapFolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 의존성 주입 (Dependency Injection) - 수동 버전
    final contactRepository = ContactRepositoryImpl();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapFolio!',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactListPage(repository: contactRepository),
    );
  }
}