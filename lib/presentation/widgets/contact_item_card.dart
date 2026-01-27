import 'package:flutter/material.dart';
import 'dart:math' show min;
import '../../domain/entities/contact.dart';

class ContactItemCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactItemCard({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // ★ 1. 프로필 영역 (수정됨)
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300], // 배경색 살짝 연하게
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                // ★ 사진이 있으면 배경이미지로 꽉 채우기!
                image: contact.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(contact.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // 사진 없을 때만 사람 아이콘 보여주기
              child: contact.profileImageUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            
            // 2. 정보 영역 (기존 그대로)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 8),
                    Expanded(child: _buildResponsiveGrid(contact.photoCount)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (아래 _buildInfoSection, _buildResponsiveGrid 함수들은 네가 짠 그대로 두면 됨)
  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "이름: ${contact.name}",
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "나이: ${contact.age} / 특징: ${contact.tag}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(int photoCount) {
    if (photoCount == 0) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        const double spacing = 8.0;
        final double targetSquareSide = availableHeight;

        if (targetSquareSide <= 0) return const SizedBox();

        int maxPossibleFitCount =
            ((availableWidth + spacing) / (targetSquareSide + spacing)).floor();
        int displayCount = min(photoCount, maxPossibleFitCount);

        if (displayCount <= 0) return const SizedBox();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(displayCount, (index) {
            bool isLastItem = index == displayCount - 1;
            bool showOverlay = isLastItem && (photoCount > displayCount);
            int plusNumber = photoCount - (displayCount - 1);

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
                    "https://picsum.photos/seed/${contact.name}$index/200",
                    fit: BoxFit.cover,
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