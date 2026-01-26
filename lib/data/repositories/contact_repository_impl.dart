import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  // 파이어스토어 인스턴스 (창고 관리인)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Contact>> getContacts() async {
    try {
      // 1. 'contacts' 컬렉션에 있는 거 다 내놔 (비동기)
      final snapshot = await _firestore.collection('contacts').get();

      // 2. 가져온 데이터를 자바스크립트(JSON)에서 다트 객체로 변환
      return snapshot.docs.map((doc) {
        final data = doc.data(); // 껍질 까기

        return Contact(
          name: data['name'] ?? 'Unknown', // 데이터 없으면 기본값
          age: data['age'] ?? 0,
          tag: data['tag'] ?? '',
          photoCount: data['photoCount'] ?? 0,
        );
      }).toList();
      
    } catch (e) {
       print("🔥 데이터 가져오다 불남: $e");
      return []; // 에러 나면 빈 리스트 던져줌 (앱 안 죽게)
    }
  }
}