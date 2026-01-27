import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // (getContacts, addContact, addGalleryPhoto는 기존과 동일 - 생략)
  @override
  Future<List<Contact>> getContacts() async {
    // ... (기존 코드 유지)
    // 전체 코드를 덮어쓰실 거면 이전 답변의 코드를 참고하되, 아래 getGalleryPhotos만 바꾸셔도 됩니다.
    // 편의를 위해 전체 흐름이 안 끊기게 아래 부분만 집중적으로 보여드립니다.
    try {
      final snapshot = await _firestore
          .collection('contacts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Contact(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          age: data['age'] ?? 0,
          tag: data['tag'] ?? '',
          photoCount: data['photoCount'] ?? 0,
          profileImageUrl: data['profileImageUrl'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addContact(String name, String age, String tag, String? imageUrl) async {
    // ... (기존 코드 유지)
    await _firestore.collection('contacts').add({
      'name': name,
      'age': int.tryParse(age) ?? 0,
      'tag': tag,
      'profileImageUrl': imageUrl,
      'photoCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addGalleryPhoto(String contactId, String imageUrl) async {
    // ... (기존 코드 유지)
     try {
      await _firestore
          .collection('contacts')
          .doc(contactId)
          .collection('photos')
          .add({
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('contacts').doc(contactId).update({
        'photoCount': FieldValue.increment(1),
      });
    } catch (e) {
      print("앨범 저장 실패: $e");
    }
  }

  // ★★★ 여기가 핵심 수정! ★★★
  @override
  Future<List<String>> getGalleryPhotos(String contactId, {int? limit}) async {
    try {
      // 1. 쿼리 기본 설정 (정렬)
      Query query = _firestore
          .collection('contacts')
          .doc(contactId)
          .collection('photos')
          .orderBy('createdAt', descending: true);

      // 2. 만약 limit이 있으면 제한 걸기 (리스트 화면용)
      if (limit != null) {
        query = query.limit(limit);
      }

      // 3. 가져오기
      final snapshot = await query.get();

      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ★ 1. 프로필 사진 업데이트 구현
  @override
  Future<void> updateProfileImage(String contactId, String newImageUrl) async {
    try {
      await _firestore.collection('contacts').doc(contactId).update({
        'profileImageUrl': newImageUrl,
      });
    } catch (e) {
      print("프로필 수정 실패: $e");
    }
  }

  // ★ 2. 갤러리 사진 삭제 구현
  @override
  Future<void> deleteGalleryPhoto(String contactId, String photoUrl) async {
    try {
      // (1) URL이 일치하는 사진 문서를 찾아서 삭제
      // (기존 코드를 안 깨뜨리려고 URL로 찾습니다)
      final querySnapshot = await _firestore
          .collection('contacts')
          .doc(contactId)
          .collection('photos')
          .where('imageUrl', isEqualTo: photoUrl)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // (2) 사진 개수 -1 감소 (0보다 작아지진 않게)
      await _firestore.collection('contacts').doc(contactId).update({
        'photoCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print("사진 삭제 실패: $e");
    }
  }
}