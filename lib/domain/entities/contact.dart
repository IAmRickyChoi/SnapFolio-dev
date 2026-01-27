class Contact {
  final String id; // ★ 추가됨: DB 문서 ID (신분증)
  final String name;
  final int age;
  final String tag;
  final int photoCount;
  final String? profileImageUrl;

  const Contact({
    required this.id, // ★ 필수값으로 변경
    required this.name,
    required this.age,
    required this.tag,
    required this.photoCount,
    this.profileImageUrl,
  });
}