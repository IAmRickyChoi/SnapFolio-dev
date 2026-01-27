import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(String name, String age, String tag, String? imageUrl);

  // ★ 앨범 관련 기능 2개 추가
  Future<void> addGalleryPhoto(String contactId, String imageUrl); // 사진 추가
  Future<List<String>> getGalleryPhotos(String contactId);         // 사진 목록 가져오기
}