import 'package:flutter/material.dart';
import '../../data/repositories/image_repository.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _imageRepo = ImageRepository();
  String? _profileImageUrl;

  // ★ 컨트롤러 3개로 확실하게 분리!
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();     // 나이용
  final _featureController = TextEditingController(); // 특징용

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
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            // 나이 입력창
            TextField(
              controller: _ageController, // ★ 여기 바꿈!
              keyboardType: TextInputType.number, // 나이니까 숫자 키패드
              decoration: const InputDecoration(
                labelText: '나이',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // 특징 입력창
            TextField(
              controller: _featureController, // ★ 여기 바꿈!
              decoration: const InputDecoration(
                labelText: '특징',
                border: OutlineInputBorder(),
              ),
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
          onPressed: () {
            // 일단 UI만 저장하는 단계니까 프린트로 확인
            print("이름: ${_nameController.text}");
            print("나이: ${_ageController.text}");
            print("특징: ${_featureController.text}");
            print("사진: $_profileImageUrl");

            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}