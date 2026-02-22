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
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: const Center(child: Text('Add New Contact')),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  CircleAvatar(
                    radius: 50,

                    backgroundColor: Colors.grey[200],

                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                  ),

                  if (_profileImageUrl == null)
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.grey[600],
                      size: 30,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,

              decoration: InputDecoration(
                labelText: 'Name',

                prefixIcon: const Icon(Icons.person_outline),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _ageController,

              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: 'Birth',

                prefixIcon: const Icon(Icons.cake_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _featureController,

              decoration: InputDecoration(
                labelText: 'Tag',

                prefixIcon: const Icon(Icons.tag),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),

      actionsAlignment: MainAxisAlignment.center,

      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),

      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),

                child: const Text('Cancel'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () async {
                  if (_nameController.text.isEmpty) return;

                  final repository = ContactRepositoryImpl();

                  await repository.addContact(
                    _nameController.text,

                    _ageController.text,

                    _featureController.text,

                    _profileImageUrl,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
