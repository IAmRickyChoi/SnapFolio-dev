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
  final _imageRepo = ImageRepository(); // 이미지 업로드용

  List<String> _galleryPhotos = []; // 화면에 보여줄 사진 리스트
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery(); // 들어오자마자 앨범 불러오기
  }

  // 앨범 사진 로딩
  Future<void> _loadGallery() async {
    final photos = await _contactRepo.getGalleryPhotos(widget.contact.id);
    if (mounted) {
      setState(() {
        _galleryPhotos = photos;
        _isLoading = false;
      });
    }
  }

  // ★ 사진 추가 버튼 눌렀을 때
  Future<void> _addPhoto() async {
    // 1. 갤러리 열어서 사진 선택 및 업로드
    final url = await _imageRepo.pickAndUploadImage();
    
    if (url != null) {
      // 로딩 표시 (UX)
      setState(() => _isLoading = true);

      // 2. DB에 저장 (이 사람의 앨범에 추가)
      await _contactRepo.addGalleryPhoto(widget.contact.id, url);

      // 3. 목록 새로고침
      await _loadGallery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        actions: [
          // 우측 상단 + 버튼 (사진 추가)
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
            // 프로필 사진 (크게)
            Center(
              child: Hero(
                tag: widget.contact.id, // 애니메이션 효과
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: widget.contact.profileImageUrl != null
                      ? NetworkImage(widget.contact.profileImageUrl!)
                      : null,
                  child: widget.contact.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 정보 섹션
            Text('이름: ${widget.contact.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('나이: ${widget.contact.age}세', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text('특징: ${widget.contact.tag}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            
            const Divider(height: 40, thickness: 1),
            
            // 갤러리 섹션
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

            // 사진 그리드
            _galleryPhotos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("사진을 추가해보세요!", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤은 전체 페이지가 담당
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 줄에 3개
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _galleryPhotos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // (심화) 나중에 여기 누르면 사진 크게 보기 기능 넣을 수 있음
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(_galleryPhotos[index]),
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