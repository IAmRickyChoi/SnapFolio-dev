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
  
  // 프로필 사진이 바뀌면 화면에 바로 반영하기 위해 변수로 관리
  String? _currentProfileUrl; 

  @override
  void initState() {
    super.initState();
    _currentProfileUrl = widget.contact.profileImageUrl; // 초기값 설정
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("프로필 사진이 변경되었습니다!")),
        );
      }
    }
  }

  Future<void> _addPhoto() async {
    final url = await _imageRepo.pickAndUploadImage();
    if (url != null) {
      setState(() => _isLoading = true);
      await _contactRepo.addGalleryPhoto(widget.contact.id, url);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사진이 삭제되었습니다.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        actions: [
          IconButton(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ★ 프로필 사진 영역 (클릭 가능하게 변경)
            Center(
              child: GestureDetector(
                onTap: _changeProfileImage, // 클릭하면 변경 함수 실행
                child: Stack(
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
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                    // 카메라 아이콘 배지 (수정 가능하다는 힌트)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('이름: ${widget.contact.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('나이: ${widget.contact.age}세', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text('특징: ${widget.contact.tag}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            
            const Divider(height: 40, thickness: 1),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '갤러리 (${_galleryPhotos.length}장)', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 16),

            _galleryPhotos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("사진을 추가해보세요!", style: TextStyle(color: Colors.grey)),
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
                        // ★ 꾹 누르면 삭제 함수 실행
                        onLongPress: () => _deletePhoto(photoUrl),
                        onTap: () {
                           // (나중에 크게 보기 기능 넣을 곳)
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}