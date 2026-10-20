# Object Storage Server (MinIO S3 Compatible)

## Thông tin kết nối
- **MinIO S3 API:** `http://localhost:9000` (hoặc `http://<EC2_IP>:9000`)
- **MinIO Web Console:** `http://localhost:9001` (hoặc `http://<EC2_IP>:9001`)
- **Username:** `minioadmin`
- **Password:** `minioadmin`

## Hướng dẫn cấu hình (Mở rộng 5)
1. Truy cập vào **MinIO Web Console** tại port `9001`.
2. Tạo các Buckets:
   - `demo`: Dành cho kiểm thử cơ bản.
   - `profile-pics`: Dành cho lưu ảnh đại diện (Set Access Policy thành **Public** và tải lên file `avatar.jpg`).
   - `documents`: Dành cho lưu trữ tài liệu (Tải lên file PDF minh chứng).
3. Sử dụng AWS CLI hoặc MinIO Client (mc) nếu muốn tự động hóa:
   ```bash
   mc alias set myminio http://localhost:9000 minioadmin minioadmin
   mc mb myminio/profile-pics
   mc anonymous set public myminio/profile-pics
   mc mb myminio/documents
   ```
