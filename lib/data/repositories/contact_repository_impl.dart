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
  Future<void> addGalleryPhotos(String contactId, List<String> imageUrls) async {
    try {
      final contactRef = _firestore.collection('contacts').doc(contactId);
      final photosRef = contactRef.collection('photos');
      
      WriteBatch batch = _firestore.batch();

      for (var imageUrl in imageUrls) {
        final newPhotoDoc = photosRef.doc();
        batch.set(newPhotoDoc, {
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      batch.update(contactRef, {
        'photoCount': FieldValue.increment(imageUrls.length),
      });

      await batch.commit();
    } catch (e) {
      print("갤러리 여러장 저장 실패: $e");
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

    @override

    Future<void> updateContactInfo(String contactId, String name, String age, String tag) async {

      try {

        await _firestore.collection('contacts').doc(contactId).update({

          'name': name,

          'age': int.tryParse(age) ?? 0,

          'tag': tag,

        });

      } catch (e) {

        print("정보 수정 실패: $e");

        throw Exception('수정 중 오류 발생');

      }

    }

  

    @override

    Future<void> deleteContact(String contactId) async {

      try {

        await _firestore.collection('contacts').doc(contactId).delete();

      } catch (e) {

        print("연락처 삭제 실패: $e");

        throw Exception('삭제 중 오류 발생');

      }

    }

  }

  