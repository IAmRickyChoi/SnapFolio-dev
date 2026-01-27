import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Contact>> getContacts() async {
    try {
      final snapshot = await _firestore
          .collection('contacts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Contact(
          id: doc.id, // ★ 중요: DB의 문서 ID를 가져와서 담음!
          name: data['name'] ?? 'Unknown',
          age: data['age'] ?? 0,
          tag: data['tag'] ?? '',
          photoCount: data['photoCount'] ?? 0,
          profileImageUrl: data['profileImageUrl'],
        );
      }).toList();
    } catch (e) {
      print("🔥 데이터 가져오다 에러남: $e");
      return [];
    }
  }

  @override
  Future<void> addContact(String name, String age, String tag, String? imageUrl) async {
    await _firestore.collection('contacts').add({
      'name': name,
      'age': int.tryParse(age) ?? 0,
      'tag': tag,
      'profileImageUrl': imageUrl,
      'photoCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ★ 1. 개인 앨범에 사진 추가하기
  @override
  Future<void> addGalleryPhoto(String contactId, String imageUrl) async {
    try {
      // (1) 서브 컬렉션 'photos'에 사진 주소 저장
      await _firestore
          .collection('contacts')
          .doc(contactId)
          .collection('photos')
          .add({
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // (2) 사진 개수(photoCount) +1 증가 시키기
      await _firestore.collection('contacts').doc(contactId).update({
        'photoCount': FieldValue.increment(1),
      });
    } catch (e) {
      print("앨범 저장 실패: $e");
    }
  }

  // ★ 2. 개인 앨범 사진들 가져오기
  @override
  Future<List<String>> getGalleryPhotos(String contactId) async {
    try {
      final snapshot = await _firestore
          .collection('contacts')
          .doc(contactId)
          .collection('photos')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}