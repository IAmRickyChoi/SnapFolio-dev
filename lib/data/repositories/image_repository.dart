import 'dart:io';
import 'dart:typed_data'; // ★ 추가됨
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepository {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<String?> pickAndUploadImage() async {
    try {
      // 1. 갤러리 열기
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      File file = File(image.path);
      String fileName = 'contacts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      // ★ 메타데이터 설정 (이건 유지)
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // ====================================================
      // ★ 핵심 수정: putFile 대신 putData 사용!
      // (iOS 시뮬레이터 -1017 에러 회피용 필살기)
      // ====================================================
      Uint8List fileBytes = await file.readAsBytes();
      await ref.putData(fileBytes, metadata);
      // ====================================================

      // 3. 다운로드 주소 받기
      String downloadUrl = await ref.getDownloadURL();
      print("✅ 진짜 업로드 성공! 주소: $downloadUrl");
      
      return downloadUrl;

    } catch (e) {
      print("🔥 사진 업로드 실패 (에러코드 확인): $e");
      return null;
    }
  }
}