import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  @override
  Future<List<Contact>> getContacts() async {
    // 나중에 여기서 Firestore.instance.collection... 하면 됨
    // 지금은 네트워크 딜레이 흉내(Future)만 냄
    await Future.delayed(const Duration(milliseconds: 500)); 

    return [
      const Contact(name: "Ricky Choi", age: 27, tag: "Flutter Specialist", photoCount: 10),
      const Contact(name: "Kim Dart", age: 30, tag: "Backend Dev", photoCount: 4),
      const Contact(name: "Lee Widget", age: 22, tag: "Newbie", photoCount: 2),
      const Contact(name: "Alice UI", age: 35, tag: "Designer", photoCount: 0),
      const Contact(name: "Bob Longname", age: 29, tag: "Overflow Test Text Long", photoCount: 15),
    ];
  }
}