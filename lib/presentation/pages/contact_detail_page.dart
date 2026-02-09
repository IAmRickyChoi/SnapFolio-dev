import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../data/repositories/image_repository.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final _contactRepo = ContactRepositoryImpl();
  final _imageRepo = ImageRepository();

  List<String> _galleryPhotos = [];
  bool _isLoading = true;

  // State for multi-delete
  bool _isSelectionMode = false;
  final List<String> _selectedPhotos = [];

  // State for contact info
  late String _name;
  late int _age;
  late String _tag;
  String? _currentProfileUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.contact.name;
    _age = widget.contact.age;
    _tag = widget.contact.tag;
    _currentProfileUrl = widget.contact.profileImageUrl;
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final photos = await _contactRepo.getGalleryPhotos(widget.contact.id);
    if (mounted) {
      setState(() {
        _galleryPhotos = photos;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeProfileImage() async {
    final newUrl = await _imageRepo.pickAndUploadImage();
    if (newUrl != null) {
      setState(() => _isLoading = true);
      await _contactRepo.updateProfileImage(widget.contact.id, newUrl);
      setState(() {
        _currentProfileUrl = newUrl;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("프로필 사진이 변경되었습니다!")));
      }
    }
  }

  Future<void> _addPhoto() async {
    final urls = await _imageRepo.pickAndUploadMultipleImages();
    if (urls.isNotEmpty) {
      setState(() => _isLoading = true);
      await _contactRepo.addGalleryPhotos(widget.contact.id, urls);
      await _loadGallery();
    }
  }

  Future<void> _deleteSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${_selectedPhotos.length}개의 사진 삭제"),
        content: const Text("선택한 사진들을 갤러리에서 지우시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _contactRepo.deleteGalleryPhotos(widget.contact.id, _selectedPhotos);
      _exitSelectionMode();
      await _loadGallery();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_selectedPhotos.length}개의 사진이 삭제되었습니다.")));
      }
    }
  }
  
  void _editContactInfo() async {
    final nameController = TextEditingController(text: _name);
    final ageController = TextEditingController(text: _age.toString());
    final tagController = TextEditingController(text: _tag);
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('정보 수정'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: '이름')),
            TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '나이')),
            TextField(controller: tagController, decoration: const InputDecoration(labelText: '특징')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  await _contactRepo.updateContactInfo(widget.contact.id, nameController.text, ageController.text, tagController.text);
                  if (mounted) {
                    setState(() {
                      _name = nameController.text;
                      _age = int.tryParse(ageController.text) ?? 0;
                      _tag = tagController.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("정보가 수정되었습니다!")));
                  }
                },
                child: const Text('저장')),
          ],
        ));
  }

  void _onPhotoTap(String photoUrl) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedPhotos.contains(photoUrl)) {
          _selectedPhotos.remove(photoUrl);
          if (_selectedPhotos.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedPhotos.add(photoUrl);
        }
      });
    }
  }

  void _onPhotoLongPress(String photoUrl) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedPhotos.add(photoUrl);
      });
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPhotos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(theme),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(Theme.of(context)),
                const SizedBox(height: 24),
                _buildGallerySection(Theme.of(context)),
              ],
            ),
          ),
          if (_isLoading)
            Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedPhotos.length}개 선택됨'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSelectedPhotos,
            tooltip: '삭제',
          ),
        ],
      );
    } else {
      return AppBar(
        title: Text(_name),
        actions: [
          IconButton(onPressed: _editContactInfo, icon: const Icon(Icons.edit_note), tooltip: "정보 수정"),
          IconButton(onPressed: _addPhoto, icon: const Icon(Icons.add_a_photo_outlined), tooltip: "사진 추가"),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      );
    }
  }

  Widget _buildProfileCard(ThemeData theme) {
    // This widget's implementation remains the same
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(children: [
          GestureDetector(
              onTap: _changeProfileImage,
              child: Stack(alignment: Alignment.bottomRight, children: [
                Hero(
                  tag: widget.contact.id,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _currentProfileUrl != null ? NetworkImage(_currentProfileUrl!) : null,
                    child: _currentProfileUrl == null ? Icon(Icons.person, size: 60, color: Colors.grey[400]) : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration:
                      BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.edit, size: 20, color: Colors.white),
                ),
              ])),
          const SizedBox(height: 16),
          Text(_name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildInfoTile(theme, Icons.cake_outlined, 'Age', '$_age세'),
            _buildInfoTile(theme, Icons.tag, 'Tag', _tag),
          ]),
        ]),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    // This widget's implementation remains the same
    return Column(children: [
      Icon(icon, color: theme.colorScheme.primary, size: 28),
      const SizedBox(height: 8),
      Text(label, style: theme.textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildGallerySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gallery (${_galleryPhotos.length})', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _galleryPhotos.isEmpty
            ? Container(
                height: 150,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text("사진을 추가해보세요!", style: TextStyle(color: Colors.grey))))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: _galleryPhotos.length,
                itemBuilder: (context, index) {
                  final photoUrl = _galleryPhotos[index];
                  final isSelected = _selectedPhotos.contains(photoUrl);
                  return GestureDetector(
                    onTap: () => _onPhotoTap(photoUrl),
                    onLongPress: () => _onPhotoLongPress(photoUrl),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(photoUrl, fit: BoxFit.cover)),
                        if (_isSelectionMode)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.primary.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        if (isSelected)
                          const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.check_circle, color: Colors.white, size: 40),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}
