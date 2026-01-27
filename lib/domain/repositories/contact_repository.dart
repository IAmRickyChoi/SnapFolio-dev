import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(String name, String age, String tag, String? imageUrl);

  Future<void> addGalleryPhoto(String contactId, String imageUrl);
  
  // ★ 수정됨: {int? limit} 옵션 추가!
  Future<List<String>> getGalleryPhotos(String contactId, {int? limit}); 
}