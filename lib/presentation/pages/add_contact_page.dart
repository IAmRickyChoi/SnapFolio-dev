import 'package:flutter/material.dart';
import '../../data/repositories/image_repository.dart';
import '../../data/repositories/contact_repository_impl.dart'; // ★ 추가: 저장소 불러오기

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _imageRepo = ImageRepository();
  String? _profileImageUrl;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _featureController = TextEditingController();

  Future<void> _pickImage() async {
    final url = await _imageRepo.pickAndUploadImage();
    if (url != null) {
      setState(() {
        _profileImageUrl = url;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 연락처 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(Icons.camera_alt, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '나이', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _featureController,
              decoration: const InputDecoration(labelText: '특징', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            // 1. 이름 비어있으면 저장 안 함
            if (_nameController.text.isEmpty) return;

            // 2. 저장소 불러오기
            final repository = ContactRepositoryImpl();

            // 3. 진짜 저장! (async/await 필수)
            await repository.addContact(
              _nameController.text,
              _ageController.text,
              _featureController.text,
              _profileImageUrl,
            );

            // 4. 창 닫기 (이러면 리스트 페이지가 알아서 새로고침 됨)
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}