import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(String name, String age, String tag, String? imageUrl);
  Future<void> addGalleryPhotos(String contactId, List<String> imageUrls);
  Future<List<String>> getGalleryPhotos(String contactId, {int? limit});
  Future<void> updateProfileImage(String contactId, String newImageUrl);
  Future<void> deleteGalleryPhoto(String contactId, String photoUrl);
  Future<void> updateContactInfo(String contactId, String name, String age, String tag);
  Future<void> deleteContact(String contactId);
}