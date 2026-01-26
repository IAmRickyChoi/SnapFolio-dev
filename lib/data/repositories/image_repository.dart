import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepository {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  // 1. 갤러리에서 사진 고르고 -> 바로 업로드 -> 다운로드 URL 받기 (원스톱 서비스)
  Future<String?> pickAndUploadImage() async {
    try {
      // (1) 갤러리 열기
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      // 사진 안 고르고 취소했을 경우
      if (image == null) return null;

      File file = File(image.path);

      // (2) 파일 이름 만들기 (겹치지 않게 시간으로 작명)
      String fileName = 'contacts/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // (3) 파이어베이스 스토리지(창고)로 전송
      Reference ref = _storage.ref().child(fileName);
      await ref.putFile(file);

      // (4) 업로드된 사진의 인터넷 주소(URL) 가져오기
      String downloadUrl = await ref.getDownloadURL();
      
      print("업로드 성공! 주소: $downloadUrl");
      return downloadUrl;

    } catch (e) {
      print("사진 업로드 실패: $e");
      return null;
    }
  }
}