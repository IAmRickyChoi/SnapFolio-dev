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

      return _isLoading

          ? const Center(child: CircularProgressIndicator())

          : _contacts.isEmpty 

              ? const Center(child: Text("아직 데이터가 없습니다.\n+ 버튼을 눌러보세요!"))

              : Stack( // Use Stack to place FloatingActionButton on top

                  children: [

                    ListView.separated(

                      padding: const EdgeInsets.all(16),

                      itemCount: _contacts.length,

                      separatorBuilder: (context, index) => const SizedBox(height: 16),

                      itemBuilder: (context, index) {

                        final contact = _contacts[index];

                        return Dismissible(

                          key: ValueKey(contact.id),

                          direction: DismissDirection.endToStart,

                          onDismissed: (direction) {

                            final removedContact = _contacts.removeAt(index);

                            setState(() {});

  

                            ScaffoldMessenger.of(context).showSnackBar(

                              SnackBar(

                                content: Text('${removedContact.name}이(가) 삭제되었습니다.'),

                                action: SnackBarAction(

                                  label: '실행 취소',

                                  onPressed: () {

                                    setState(() {

                                      _contacts.insert(index, removedContact);

                                    });

                                  },

                                ),

                              ),

                            ).closed.then((reason) {

                              if (reason != SnackBarClosedReason.action) {

                                widget.repository.deleteContact(removedContact.id);

                              }

                            });

                          },

                          background: Container(

                            color: Colors.red,

                            alignment: Alignment.centerRight,

                            padding: const EdgeInsets.symmetric(horizontal: 20),

                            child: const Icon(Icons.delete, color: Colors.white),

                          ),

                                                    child: ContactItemCard(

                                                      contact: contact,

                                                      repository: widget.repository,

                                                      onTap: () async {

                                                        await Navigator.push(

                                                          context,

                                                          MaterialPageRoute(

                                  builder: (context) =>

                                      ContactDetailPage(contact: contact),

                                ),

                              );

                              _loadData();

                            },

                          ),

                        );

                      },

                    ),

                    Positioned(

                      bottom: 16,

                      right: 16,

                      child: FloatingActionButton(

                        onPressed: () async { 

                          await showDialog(

                            context: context,

                            builder: (context) => const AddContactDialog(),

                          );

                          print("팝업 닫힘 -> 데이터 새로고침 시작");

                          _loadData(); 

                        },

                        child: const Icon(Icons.add),

                      ),

                    ),

                  ],

                );

    }

}