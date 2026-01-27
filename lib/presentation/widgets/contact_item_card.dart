import 'package:flutter/material.dart';
import 'dart:math' show min;
import '../../domain/entities/contact.dart';
import '../../data/repositories/contact_repository_impl.dart'; // 레포지토리 필요

class ContactItemCard extends StatefulWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactItemCard({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  State<ContactItemCard> createState() => _ContactItemCardState();
}

class _ContactItemCardState extends State<ContactItemCard> {
  late Future<List<String>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    // ★ 수정됨: 여기서 limit: 4를 넣어줍니다!
    _galleryFuture = ContactRepositoryImpl().getGalleryPhotos(
      widget.contact.id, 
      limit: 4, // "미리보기니까 4개만 줘"
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 프로필 영역
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                image: widget.contact.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.contact.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.contact.profileImageUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            
            // 2. 정보 및 앨범 미리보기 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 8),
                    
                    // ★ 여기가 핵심 변경 포인트!
                    Expanded(
                      child: FutureBuilder<List<String>>(
                        future: _galleryFuture, // 여기서 DB 요청
                        builder: (context, snapshot) {
                          // (1) 로딩 중일 때
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(color: Colors.grey[50]); // 깜빡임 최소화
                          }
                          
                          // (2) 데이터 가져왔을 때
                          final photos = snapshot.data ?? [];
                          return _buildResponsiveGrid(photos);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "이름: ${widget.contact.name}",
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          "나이: ${widget.contact.age} / 특징: ${widget.contact.tag}",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(List<String> photos) {
    int photoCount = photos.length;
    // DB에 있는 실제 총 개수 사용 (표시용)
    int totalCount = widget.contact.photoCount; 

    if (photoCount == 0) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        const double spacing = 4.0;
        // ★ [수정 전] 높이에 꽉 맞춤 (너무 커짐)
        // final double targetSquareSide = availableHeight;
        
        // ★ [수정 후] 크기를 60.0 정도로 고정 (더 많이 들어감!)
        // (화면 높이가 60보다 작을 수 있으니 안전하게 min 사용)
        final double targetSquareSide = min(availableHeight, 60.0);

        if (targetSquareSide <= 0) return const SizedBox();

        int maxPossibleFitCount =
            ((availableWidth + spacing) / (targetSquareSide + spacing)).floor();
        
        int displayCount = min(photoCount, maxPossibleFitCount);

        if (displayCount <= 0) return const SizedBox();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(displayCount, (index) {
            bool isLastItem = index == displayCount - 1;
            // 화면에 보이는 것보다 실제 사진이 더 많으면 +N 표시
            bool showOverlay = isLastItem && (totalCount > displayCount);
            int plusNumber = totalCount - (displayCount - 1);

            return Container(
              width: targetSquareSide,
              height: targetSquareSide,
              margin: EdgeInsets.only(right: isLastItem ? 0 : spacing),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photos[index], 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                  ),
                  if (showOverlay)
                    Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Text(
                          "+$plusNumber",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}