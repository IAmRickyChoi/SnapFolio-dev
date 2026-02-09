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

  // ★ 화면에 보여줄 데이터들을 변수로 관리 (수정되면 바로 반영하려고)
  late String _name;
  late int _age;
  late String _tag;
  String? _currentProfileUrl;

  @override
  void initState() {
    super.initState();
    // 초기값은 전달받은 연락처 정보로 설정
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

  // ★ 기능 1: 프로필 사진 변경
  Future<void> _changeProfileImage() async {
    // 1. 사진 고르고 업로드
    final newUrl = await _imageRepo.pickAndUploadImage();

    if (newUrl != null) {
      setState(() => _isLoading = true); // 로딩 시작

      // 2. DB 업데이트
      await _contactRepo.updateProfileImage(widget.contact.id, newUrl);

      // 3. 화면 갱신
      setState(() {
        _currentProfileUrl = newUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("프로필 사진이 변경되었습니다!")));
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

  // ★ 기능 2: 갤러리 사진 삭제
  Future<void> _deletePhoto(String photoUrl) async {
    // 진짜 지울 건지 물어보기 (팝업)
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("사진 삭제"),
        content: const Text("이 사진을 갤러리에서 지우시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      // 1. DB에서 삭제
      await _contactRepo.deleteGalleryPhoto(widget.contact.id, photoUrl);

      // 2. 목록 새로고침
      await _loadGallery();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("사진이 삭제되었습니다.")));
      }
    }
  }
  // ★ 기능 추가: 정보 수정 팝업 띄우기
  Future<void> _editContactInfo() async {
    // 현재 정보를 컨트롤러에 미리 채워넣기
    final nameController = TextEditingController(text: _name);
    final ageController = TextEditingController(text: _age.toString());
    final tagController = TextEditingController(text: _tag);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '나이'),
            ),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(labelText: '특징'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              // 1. DB 업데이트 요청
              await _contactRepo.updateContactInfo(
                widget.contact.id,
                nameController.text,
                ageController.text,
                tagController.text,
              );

              // 2. 화면 데이터 갱신
              if (mounted) {
                setState(() {
                  _name = nameController.text;
                  _age = int.tryParse(ageController.text) ?? 0;
                  _tag = tagController.text;
                });
                Navigator.pop(context); // 팝업 닫기

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("정보가 수정되었습니다!")));
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
            onPressed: _editContactInfo,
            icon: const Icon(Icons.edit_note),
            tooltip: "정보 수정",
          ),
          IconButton(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: "사진 추가",
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(theme),
                const SizedBox(height: 24),
                _buildGallerySection(theme),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: widget.contact.id,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _currentProfileUrl != null
                          ? NetworkImage(_currentProfileUrl!)
                          : null,
                      child: _currentProfileUrl == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoTile(theme, Icons.cake_outlined, 'Age', '$_age세'),
                _buildInfoTile(theme, Icons.tag, 'Tag', _tag),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGallerySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery (${_galleryPhotos.length})',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _galleryPhotos.isEmpty
            ? Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "사진을 추가해보세요!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _galleryPhotos.length,
                itemBuilder: (context, index) {
                  final photoUrl = _galleryPhotos[index];
                  return GestureDetector(
                    onLongPress: () => _deletePhoto(photoUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(photoUrl, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
