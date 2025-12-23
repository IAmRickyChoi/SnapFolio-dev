import '../entities/contact.dart';

// 인터페이스만 정의한다. (구현은 Data 계층이 알아서 함)
abstract class ContactRepository {
  Future<List<Contact>> getContacts();
}