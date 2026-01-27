import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(String name, String age, String tag, String? imageUrl);
  Future<void> addGalleryPhoto(String contactId, String imageUrl);
  Future<List<String>> getGalleryPhotos(String contactId, {int? limit});
  Future<void> updateProfileImage(String contactId, String newImageUrl);
  Future<void> deleteGalleryPhoto(String contactId, String photoUrl);

  // ★ 추가됨: 이름, 나이, 특징 수정
  Future<void> updateContactInfo(String contactId, String name, String age, String tag);
}