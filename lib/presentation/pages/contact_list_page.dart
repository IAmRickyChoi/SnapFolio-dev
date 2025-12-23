import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../widgets/contact_item_card.dart';
import 'contact_detail_page.dart'; // (상세 페이지 파일은 아래에 생성)

class ContactListPage extends StatefulWidget {
  final ContactRepository repository;

  const ContactListPage({super.key, required this.repository});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  // 나중엔 Riverpod으로 대체될 부분
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.repository.getContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SnapFolio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ContactItemCard(
                  contact: _contacts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailPage(contact: _contacts[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}