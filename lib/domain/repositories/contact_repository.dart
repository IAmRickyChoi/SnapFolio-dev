import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(String name, String age, String tag, String? imageUrl);
  Future<void> addGalleryPhoto(String contactId, String imageUrl);
  Future<List<String>> getGalleryPhotos(String contactId, {int? limit});

  // ★ 추가됨: 프로필 사진 변경
  Future<void> updateProfileImage(String contactId, String newImageUrl);

  // ★ 추가됨: 갤러리 사진 삭제
  Future<void> deleteGalleryPhoto(String contactId, String photoUrl);
}