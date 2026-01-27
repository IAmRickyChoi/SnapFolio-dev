import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../widgets/contact_item_card.dart';
import 'contact_detail_page.dart';
import 'add_contact_page.dart';

class ContactListPage extends StatefulWidget {
  final ContactRepository repository;

  const ContactListPage({super.key, required this.repository});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 데이터 가져오는 함수
  Future<void> _loadData() async {
    // 로딩 시작 (원하면 setState로 _isLoading = true 넣어도 됨)
    final data = await widget.repository.getContacts();
    
    if (mounted) {
      setState(() {
        _contacts = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SnapFolio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty 
              ? const Center(child: Text("아직 데이터가 없습니다.\n+ 버튼을 눌러보세요!"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contacts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  // ... (위쪽 코드는 그대로)

            itemBuilder: (context, index) {
              return ContactItemCard(
                contact: _contacts[index],
                // ★ 수정된 부분 시작
                onTap: () async { // 1. async 추가
                  // 2. 상세 페이지 다녀올 때까지 기다림 (await)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactDetailPage(contact: _contacts[index]),
                    ),
                  );
                  
                  // 3. 갔다 오면 데이터 새로고침! (이게 있어야 숫자가 바뀜)
                  _loadData(); 
                },
                // ★ 수정된 부분 끝
              );
            },

// ... (아래쪽 코드는 그대로)
                ),
      floatingActionButton: FloatingActionButton(
        // ★ 여기가 핵심 수정 포인트!
        onPressed: () async { 
          // 1. 팝업창 띄우고, 닫힐 때까지 기다림 (await)
          await showDialog(
            context: context,
            builder: (context) => const AddContactDialog(),
          );
          
          // 2. 팝업창이 닫히면 바로 목록 새로고침!
          print("팝업 닫힘 -> 데이터 새로고침 시작");
          _loadData(); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}