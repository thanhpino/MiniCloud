# ☁️ MINICLOUD - MÔ PHỎNG HỆ THỐNG ĐIỆN TOÁN ĐÁM MÂY

> **ĐỒ ÁN CUỐI KỲ MÔN ĐIỆN TOÁN ĐÁM MÂY**  
> **TRƯỜNG ĐẠI HỌC TÔN ĐỨC THẮNG (TDTU) - KHOA CÔNG NGHỆ THÔNG TIN**  

Hệ thống **MiniCloud** được thiết kế và xây dựng nhằm mô phỏng một nền tảng Cloud Platform thu nhỏ hoàn chỉnh (tương đương AWS, GCP, Azure) với **9 loại máy chủ chuyên biệt**, vận hành trong các Docker container độc lập, kết nối qua mạng cô lập `cloud-net` (Subnet: `172.28.0.0/16`) và triển khai thực tế trên **máy Local** cùng **AWS EC2 (Ubuntu)**.

---

## 👥 THÔNG TIN SINH VIÊN THỰC HIỆN

| STT | Họ và Tên | Mã số sinh viên (MSSV) | Vai trò & Phụ trách kỹ thuật |
| :---: | :--- | :---: | :---: |
| **1** | **Trương Minh Thành** | **524H0032** | **Lead Infra, Security, Monitoring & Cloud Deploy:**<br>- Bind9 Internal DNS (`db.cloud.local`)<br>- Prometheus & Node Exporter Metrics Scrape<br>- Grafana Dashboard giám sát System Health<br>- Keycloak OIDC IAM Identity Server (`realm_524h0032_524h0125`)<br>- Nginx API Gateway & Round Robin Load Balancer 2 Web Nodes<br>- Hạ tầng AWS EC2, Swap RAM, Security Groups |
| **2** | **Trương Cao Sang**  | **524H0125** | **Lead Application, Database, Storage & Docker Hub:**<br>- Web Server 1 & Web Server 2 (Modern Responsive HTML & 3 Blog Posts)<br>- Flask REST API Backend (`/hello`, `/student`, `/students-db`, `/secure`)<br>- MariaDB RDS (`minicloud` & `studentdb`)<br>- MinIO S3-Compatible Object Storage (`profile-pics`, `documents`)<br>- Đóng gói & Phát hành Images trên Docker Hub (`bevissava`) |

---

## 🗺️ BẢN ĐỒ MẠNG & PHÂN ĐỊNH DỊCH VỤ (`cloud-net: 172.28.0.0/16`)

| STT | Tên Service | Container Name | IP Nội Bộ | Cổng Host Exposed | Chức Năng & Vai Trò | Người Phụ Trách |
| :---: | :--- | :--- | :---: | :---: | :--- | :--- |
| **1** | `api-gateway-proxy-server` | `api-gateway-proxy-server` | `172.28.0.10` | `80:80` | Reverse Proxy gom cổng & Round Robin Load Balancer | **Trương Minh Thành** |
| **2** | `internal-dns-server` | `internal-dns-server` | `172.28.0.53` | `1053:53` | Bind9 DNS phân giải tên miền nội bộ `*.cloud.local` | **Trương Minh Thành** |
| **3** | `monitoring-prometheus-server` | `monitoring-prometheus-server` | `172.28.0.60` | `9090:9090` | Thu thập metrics từ Node Exporter và Web Nodes | **Trương Minh Thành** |
| **4** | `monitoring-node-exporter-server` | `monitoring-node-exporter-server` | `172.28.0.61` | `9100:9100` | Xuất thông số hiệu năng hạt nhân Linux (CPU/RAM/Disk/Net) | **Trương Minh Thành** |
| **5** | `monitoring-grafana-dashboard-server` | `monitoring-grafana-dashboard-server` | `172.28.0.62` | `3000:3000` | Trực quan hóa dữ liệu giám sát với 3 biểu đồ PromQL | **Trương Minh Thành** |
| **6** | `authentication-identity-server` | `authentication-identity-server` | `172.28.0.50` | `8081:8080` | Keycloak Identity Provider (OIDC / OAuth2 / JWT) | **Trương Minh Thành** |
| **7** | `web-frontend-server` | `web-frontend-server` | `172.28.0.11` | `8080:80` | Web Frontend Node 1 (Website tĩnh & Blog cá nhân 3 bài) | **Trương Cao Sang** |
| **8** | `web-frontend-server2` | `web-frontend-server2` | `172.28.0.12` | `8082:80` | Web Frontend Node 2 (Cân bằng tải Round Robin) | **Trương Cao Sang** |
| **9** | `application-backend-server` | `application-backend-server` | `172.28.0.20` | `5000:5000` | Flask REST API Server (Xử lý logic, kết nối DB & verify Token) | **Trương Cao Sang** |
| **10** | `relational-database-server` | `relational-database-server` | `172.28.0.30` | `3306:3306` | MariaDB RDS (`minicloud` bảng `notes` & `studentdb` bảng `students`) | **Trương Cao Sang** |
| **11** | `object-storage-server` | `object-storage-server` | `172.28.0.40` | `9000:9000`<br>`9001:9001` | MinIO Object Storage tương thích Amazon S3 | **Trương Cao Sang** |

---

## 📦 DOCKER HUB REGISTRY 

Các Docker Images tùy chỉnh của dự án đã được build chuẩn kiến trúc `linux/amd64` và phát hành công khai (Public) trên Docker Hub bởi thành viên **Trương Cao Sang**:

- 🌐 **Web Frontend Node 1:** [`bevissava/myminicloud-web:v1`](https://hub.docker.com/r/bevissava/myminicloud-web)
- 🌐 **Web Frontend Node 2:** [`bevissava/myminicloud-web2:v1`](https://hub.docker.com/r/bevissava/myminicloud-web2)
- ⚙️ **Application Backend API:** [`bevissava/myminicloud-backend:v1`](https://hub.docker.com/r/bevissava/myminicloud-backend)

---

## 🚀 HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### 1. Yêu cầu môi trường
- Hệ điều hành: Windows (WSL2 / Docker Desktop) hoặc Linux Ubuntu 22.04 LTS
- Docker Engine >= 24.x
- Docker Compose >= 2.x
- Git

### 2. Thiết lập cấu hình môi trường (`.env`)
Trước khi khởi chạy lần đầu tiên, tạo file `.env` từ file mẫu:
```bash
cp .env.example .env
```
Nội dung file `.env` mặc định sử dụng registry đã được build sẵn:
```env
DOCKERHUB_USERNAME=bevissava
```

### 3. Khởi chạy toàn bộ hệ thống
```bash
# Tải các image từ Docker Hub và khởi chạy các container
# nếu khởi chạy ngầm thì thêm cờ -d
docker compose up -d

# Kiểm tra trạng thái hoạt động của toàn bộ 11 containers
docker compose ps
```

---

## KỊCH BẢN KIỂM THỬ ĐẦY ĐỦ

### 1. Web Frontend & Cân bằng tải Round Robin (Trương Cao Sang & Trương Minh Thành)
- **Truy cập trực tiếp Web 1:** `http://localhost:8080/` (HTTP 200 OK)
- **Truy cập trực tiếp Web 2:** `http://localhost:8082/` (HTTP 200 OK)
- **Blog cá nhân 3 bài viết:** `http://localhost:8080/blog/` (Có đầy đủ `blog1.html`, `blog2.html`, `blog3.html` kèm ảnh minh họa và hyperlink quay lại trang chủ).
- **Kiểm tra cân bằng tải qua API Gateway (Port 80):**
  ```bash
  # Gọi liên tục để thấy header X-Upstream-Backend luân phiên giữa 172.28.0.11:80 và 172.28.0.12:80
  curl -i http://localhost/
  ```

### 2. Application Backend Server (Trương Cao Sang)
- **API Cơ bản `/hello`:** 
  - Truy cập trực tiếp: `curl http://localhost:5000/hello`
  - Truy cập qua Proxy: `curl http://localhost/api/hello`
  - *Kỳ vọng:* Trả về JSON `{"message": "Hello from MiniCloud Backend API!", "status": "success"}`
- **API Mở rộng `/student` (Đọc từ file `students.json`):**
  - Truy cập qua Proxy: `curl http://localhost/student/` hoặc `curl http://localhost/api/student`
  - *Kỳ vọng:* Trả về danh sách 5 sinh viên (gồm Trương Minh Thành và Trương Cao Sang ở vị trí đầu).
- **API Mở rộng `/students-db` (Kết nối truy vấn dữ liệu thực từ MariaDB):**
  - Truy cập qua Proxy: `curl http://localhost/api/students-db`
  - *Kỳ vọng:* Dữ liệu sinh viên được query trực tiếp từ database `studentdb`.

### 3. Relational Database Server - MariaDB (Trương Cao Sang)
- **Kiểm tra database `minicloud` (Cơ bản):**
  ```bash
  docker exec -it relational-database-server mariadb -uroot -proot_password -e "USE minicloud; SELECT * FROM notes;"
  ```
- **Kiểm tra database `studentdb` (Mở rộng 3):**
  ```bash
  docker exec -it relational-database-server mariadb -uroot -proot_password -e "USE studentdb; SELECT * FROM students;"
  ```

### 4. Object Storage Server - MinIO S3 (Trương Cao Sang)
1. **Truy cập MinIO Console:** `http://localhost:9001` (Tài khoản: `minioadmin` / `minioadmin`).
2. **Buckets đã tạo:**
   - `demo` (Yêu cầu cơ bản): Chứa file test index.html.
   - `profile-pics` (Mở rộng 5): Chứa ảnh đại diện cá nhân, cấu hình public download.
   - `documents` (Mở rộng 5): Chứa tài liệu báo cáo PDF.
3. **Cấp quyền Anonymous Download cho bucket `profile-pics` qua MinIO Client (`mc`):**
   ```bash
   docker exec -it object-storage-server sh -c "mc alias set myminio http://localhost:9000 minioadmin minioadmin && mc anonymous set download myminio/profile-pics"
   ```
4. **Kiểm tra truy cập Public URL:**
   `http://localhost:9000/profile-pics/<ten_anh>`

### 5. Internal DNS Server - Bind9 (Trương Minh Thành)
Kiểm tra phân giải tên miền nội bộ qua cổng `1053`:
```bash
# Phân giải web-frontend-server (Cơ bản)
dig @localhost -p 1053 web-frontend-server.cloud.local +short
# Trả về: 172.28.0.11

# Phân giải app-backend (Mở rộng 6)
dig @localhost -p 1053 app-backend.cloud.local +short
# Trả về: 172.28.0.20

# Phân giải minio & keycloak (Mở rộng 6)
dig @localhost -p 1053 minio.cloud.local +short
dig @localhost -p 1053 keycloak.cloud.local +short
```
*Hoặc chạy script tự động: `./internal-dns-server/test-dns.sh` (Linux) hoặc `./internal-dns-server/test-dns.ps1` (PowerShell).*

### 6. Monitoring Prometheus & Node Exporter (Trương Minh Thành)
1. Truy cập Prometheus: `http://localhost:9090`
2. Mở **Status** -> **Targets**:
   - `node-exporter` (Cơ bản): Trạng thái `UP` (port 9100)
   - `web-frontend` (Mở rộng 7): Trạng thái `UP` (Scrape đồng thời cả 2 web nodes port 80)
3. Truy vấn PromQL mẫu: `node_cpu_seconds_total`, `node_memory_MemAvailable_bytes`

### 7. Grafana Custom Dashboard (Trương Minh Thành)
1. Truy cập Grafana: `http://localhost:3000` (Tài khoản: `admin` / `admin`).
2. Datasource Prometheus tự động kết nối qua file provisioning.
3. Dashboard **"System Health of 524H0032 - 524H0125 (TDTU)"** nạp sẵn 3 panel biểu đồ chuẩn:
   - Panel 1: **CPU Usage (%)**
   - Panel 2: **Memory Usage**
   - Panel 3: **Network Traffic (I/O)**

### 8. Authentication & Identity - Keycloak OIDC (Trương Minh Thành)
1. Truy cập Keycloak Admin Console: `http://localhost:8081` (Tài khoản: `admin` / `admin`).
2. Realm **`realm_524h0032_524h0125`**, Client **`flask-app`**, User **`sv01`** & **`sv02`** (Mật khẩu: `password123`) tự động nạp qua `--import-realm`.
3. Kiểm thử lấy Token OIDC & kiểm tra route bảo vệ `/secure`:
   ```bash
   bash ./authentication-identity-server/test-token.sh
   # Hoặc PowerShell:
   powershell ./authentication-identity-server/test-token.ps1
   ```

### 9. Kiểm tra thông mạng toàn cụm (`cloud-net`)
Chạy lệnh kiểm tra ping giữa các container nội bộ:
```bash
docker exec -it api-gateway-proxy-server ping -c 2 web-frontend-server
docker exec -it api-gateway-proxy-server ping -c 2 application-backend-server
docker exec -it application-backend-server ping -c 2 relational-database-server
```

---

## ☁️ TRIỂN KHAI TRÊN AWS EC2 (UBUNTU LINUX)

1. **Khởi tạo EC2 Instance:** Ubuntu 22.04 LTS (Khuyên dùng `t3.small` hoặc `t3.micro`).
2. **Cấu hình Security Group (Inbound Rules):**
   - Port `22` (SSH)
   - Port `80` (API Gateway / Reverse Proxy)
   - Port `8080`, `8081`, `8085`, `3000`, `9000`, `9001`, `9090`, `1053` (Dành cho việc chấm điểm trực tiếp từng server)
3. **Bật Swap Memory 4GB (Khắc phục tràn RAM do Keycloak):**
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```
4. **Cài đặt Docker & Khởi chạy:**
   ```bash
   # Cài Docker
   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   
   # Clone code và chạy
   git clone -b dev https://github.com/thanhpino/MiniCloud.git
   cd MiniCloud
   cp .env.example .env
   docker compose pull
   docker compose up -d
   ```
5. **Truy cập qua Public IP:** `http://<EC2_PUBLIC_IP>/`

---

## 🏆 KẾT QUẢ ĐẠT ĐƯỢC
- [x] **100% Yêu cầu 9 Server cơ bản (5.0 / 5.0 Điểm)**
- [x] **100% 10 Bài tập mở rộng ứng dụng thực tế (5.0 / 5.0 Điểm)**
- [x] **Publish đầy đủ 3 Images tùy chỉnh lên Docker Hub**
- [x] **Triển khai hoàn chỉnh trên môi trường Localhost và AWS EC2**

---
*Dự án hoàn thành bởi nhóm sinh viên Trương Minh Thành & Trương Cao Sang*
*Khoa Công nghệ Thông tin - Trường Đại học Tôn Đức Thắng (TDTU).*
*Đồ án chỉ phục vụ cho mục đích môn học*
