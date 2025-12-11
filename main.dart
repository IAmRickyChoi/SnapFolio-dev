import 'package:flutter/material.dart';
import 'dart:math' show min;

// 1. 데이터 모델
class Contact {
  final String name;
  final int age;
  final String tag;
  final int photoCount; // 사진 개수

  Contact({
    required this.name,
    required this.age,
    required this.tag,
    required this.photoCount,
  });
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ContactListPage(),
  ));
}

// 2. 메인 리스트 페이지
class ContactListPage extends StatelessWidget {
  const ContactListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 테스트 데이터
    final List<Contact> contacts = [
      Contact(name: "Ricky Choi", age: 27, tag: "Flutter Technical Editor", photoCount: 10), // 많이 (공간 허용하는 만큼 표시 + 나머지)
      Contact(name: "Kim Dart", age: 30, tag: "Backend Dev", photoCount: 4),         // 적당히
      Contact(name: "Lee Widget", age: 22, tag: "Newbie", photoCount: 2),            // 적음
      Contact(name: "Alice UI", age: 35, tag: "Designer", photoCount: 0),            // 없음
      Contact(name: "Bob Longname", age: 29, tag: "Overflow Test Text Long Long Long", photoCount: 15), // 아주 많음
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Zenn Contacts')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return ContactItem(contact: contacts[index]);
        },
      ),
    );
  }
}

// 3. 리스트 아이템 (Preview UI)
class ContactItem extends StatelessWidget {
  final Contact contact;

  const ContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactDetailPage(contact: contact),
          ),
        );
      },
      child: Container(
        height: 150.0, // 전체 카드 높이 고정
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
            // [좌측] 메인 프로필 사진
            Container(
              width: 120,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),

            // [우측] 정보 + 서브 사진 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 텍스트 정보
                    Container(
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
                    ),
                    
                    const SizedBox(height: 8),

                    // 하단: 이미지 미리보기 (LayoutBuilder 사용)
                    Expanded(
                      child: contact.photoCount == 0 
                          ? const SizedBox() 
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          final double availableWidth = constraints.maxWidth;
                          final double availableHeight = constraints.maxHeight;
                          const double spacing = 8.0;

                          // 1. 정사각형 한 변의 크기 = 가용 높이 (높이에 맞춤)
                          final double targetSquareSide = availableHeight;
                          
                          if (targetSquareSide <= 0) return const SizedBox();

                          // 2. 가로 공간에 물리적으로 몇 개가 들어가는지 계산
                          // 공식: (N * Size) + ((N-1) * Spacing) <= Width
                          int maxPossibleFitCount = ((availableWidth + spacing) / (targetSquareSide + spacing)).floor();

                          // 3. 실제 표시할 개수 결정
                          // ★ 중요: 3개 제한 삭제됨.
                          // 데이터 개수와 물리적 공간 중 작은 값 선택
                          int displayCount = min(contact.photoCount, maxPossibleFitCount);

                          if (displayCount <= 0) return const SizedBox();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(displayCount, (index) {
                              // 마지막 아이템인지 확인
                              bool isLastItem = index == displayCount - 1;
                              
                              // 오버레이 표시 조건:
                              // 현재가 마지막으로 보여지는 칸이고, 실제 데이터가 더 많을 때
                              bool showOverlay = isLastItem && (contact.photoCount > displayCount);
                              
                              // 남은 개수 계산: 전체 - (현재 보여준 것들 중 마지막 빼고 나머지)
                              // 즉, 마지막 칸에 퉁쳐질 개수
                              int plusNumber = contact.photoCount - (displayCount - 1); 

                              return Container(
                                width: targetSquareSide,
                                height: targetSquareSide,
                                margin: EdgeInsets.only(right: isLastItem ? 0 : spacing),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  border: Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    const Center(child: Icon(Icons.photo, size: 16)),
                                    if (showOverlay)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
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
}

// 4. 상세 페이지
class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${contact.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('나이: ${contact.age}세'),
            Text('특징: ${contact.tag}'),
            const Divider(height: 32),
            Text('전체 갤러리 (${contact.photoCount}장)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: contact.photoCount,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(child: Text("IMG ${index + 1}")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
