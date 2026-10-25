# ☁️ MiniCloud - Microservices & Cloud Infrastructure

Hệ thống điện toán đám mây thu nhỏ mô phỏng môi trường Cloud phân tán với 9 máy chủ chuyên biệt, kết nối qua mạng cô lập `cloud-net` (Subnet: `172.28.0.0/16`).

---

## 👥 Phân Chia Vai Trò Nhóm (2 Thành Viên)

| Thành viên | Phụ trách | Trọng tâm công việc |
| :--- | :--- | :--- |
| **Thành viên A** | **Infra, Security & Monitoring** | - Bind9 Internal DNS (`db.cloud.local`)<br>- Prometheus & Node Exporter Scrape Web<br>- Grafana System Health Dashboard (CPU, RAM, Net)<br>- Keycloak OIDC IAM Server (`realm_21110001`, `flask-app`)<br>- API Gateway Nginx & Round Robin Load Balancer |
| **Thành viên B** | **Application, Data & Storage** | - Web Server 1 & Web Server 2 (HTML + Blog)<br>- Flask REST Backend (`/hello`, `/student`, `/students-db`, `/secure`)<br>- MariaDB RDS (`minicloud`, `studentdb`)<br>- MinIO Object Storage (`profile-pics`, `documents`) |

---

## 🗺️ Bản Đồ Địa Chỉ IP & Cổng Dịch Vụ (`cloud-net`)

| Service Name | Container Name | IP Nội Bộ | Cổng Host | Chức năng | Phụ trách |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `api-gateway-proxy-server` | `api-gateway-proxy-server` | `172.28.0.10` | `80:80` | Reverse Proxy & Load Balancer | **Thành viên A** |
| `internal-dns-server` | `internal-dns-server` | `172.28.0.53` | `1053:53` | Bind9 DNS phân giải `cloud.local` | **Thành viên A** |
| `monitoring-prometheus-server`| `monitoring-prometheus-server`| `172.28.0.60` | `9090:9090` | Thu thập metrics hệ thống | **Thành viên A** |
| `monitoring-node-exporter-server`| `monitoring-node-exporter-server`| `172.28.0.61` | `9100:9100` | Xuất chỉ số hạt nhân Linux | **Thành viên A** |
| `monitoring-grafana-dashboard-server`| `monitoring-grafana-dashboard-server`| `172.28.0.62` | `3000:3000` | Trực quan hóa CPU, RAM, Network | **Thành viên A** |
| `authentication-identity-server`| `authentication-identity-server`| `172.28.0.50` | `8081:8080` | Keycloak OIDC IAM Provider | **Thành viên A** |
| `web-frontend-server` | `web-frontend-server` | `172.28.0.11` | `8080:80` | Web Frontend Node 1 | Thành viên B |
| `web-frontend-server2` | `web-frontend-server2` | `172.28.0.12` | `8082:80` | Web Frontend Node 2 (Round Robin)| Thành viên B |
| `application-backend-server` | `application-backend-server` | `172.28.0.20` | `5000:5000` | Flask REST API Server | Thành viên B |
| `relational-database-server` | `relational-database-server` | `172.28.0.30` | `3306:3306` | MariaDB RDS | Thành viên B |
| `object-storage-server` | `object-storage-server` | `172.28.0.40` | `9000:9000`<br>`9001:9001` | MinIO S3 Object Storage | Thành viên B |

---

## 🚀 Hướng Dẫn Khởi Chạy

### 1. Yêu cầu chuẩn bị
- Docker Engine >= 24.x
- Docker Compose >= 2.x

### 2. Thiết lập cấu hình môi trường (.env)
Trước khi khởi chạy lần đầu tiên, hãy tạo file `.env` từ file mẫu:
```bash
cp .env.example .env
```
> **Ghi chú:** Mở file `.env` và điền tài khoản Docker Hub của bạn vào biến `DOCKERHUB_USERNAME`:
> ```env
> DOCKERHUB_USERNAME=bevissava
> ```

### 3. Khởi chạy toàn bộ hệ thống
```bash
docker compose up -d --build
```

Kiểm tra trạng thái các container:
```bash
docker compose ps
```

### 4. Tùy chỉnh Docker Hub Image (Dành cho người khác triển khai độc lập)
Nếu bạn muốn tự build và lưu trữ image trên tài khoản Docker Hub riêng:

1. **Chuẩn bị file môi trường `.env`:**
   ```bash
   cp .env.example .env
   ```
   Mở file `.env` và thay đổi `DOCKERHUB_USERNAME` thành tài khoản của bạn:
   ```env
   DOCKERHUB_USERNAME=<tai_khoan_dockerhub_cua_ban>
   ```

2. **Build và Push image lên Docker Hub cá nhân:**
   ```bash
   # Đăng nhập Docker Hub
   docker login

   # Build các custom image với kiến trúc chuẩn Linux amd64 (tương thích EC2/mọi máy chủ)
   docker build --platform linux/amd64 -t $DOCKERHUB_USERNAME/myminicloud-web:v1 ./web-frontend-server
   docker build --platform linux/amd64 -t $DOCKERHUB_USERNAME/myminicloud-web2:v1 ./web-frontend-server2
   docker build --platform linux/amd64 -t $DOCKERHUB_USERNAME/myminicloud-backend:v1 ./application-backend-server

   # Push lên Docker Hub (đảm bảo repository để chế độ Public)
   docker push $DOCKERHUB_USERNAME/myminicloud-web:v1
   docker push $DOCKERHUB_USERNAME/myminicloud-web2:v1
   docker push $DOCKERHUB_USERNAME/myminicloud-backend:v1
   ```

3. **Khởi chạy hệ thống với Image mới:**
   ```bash
   docker compose pull
   docker compose up -d
   ```

---

## 🧪 Kịch Bản Kiểm Thử Chi Tiết (Phần Thành Viên A)

### 1. Internal DNS Server (`internal-dns-server`)
Kiểm tra phân giải các bản ghi tên miền nội bộ qua cổng `1053`:
```bash
# Phân giải web-frontend-server (Cơ bản)
dig @localhost -p 1053 web-frontend-server.cloud.local +short

# Phân giải app-backend (Mở rộng 6)
dig @localhost -p 1053 app-backend.cloud.local +short

# Phân giải minio & keycloak (Mở rộng 6)
dig @localhost -p 1053 minio.cloud.local +short
dig @localhost -p 1053 keycloak.cloud.local +short
```
*Hoặc chạy script: `./internal-dns-server/test-dns.sh`*

---

### 2. Prometheus & Node Exporter (`monitoring-prometheus-server`)
1. Truy cập giao diện Prometheus: `http://localhost:9090`
2. Vào mục **Status** -> **Targets**:
   - `node-exporter` (Cơ bản): Trạng thái `UP`
   - `web-frontend` (Mở rộng 7): Trạng thái `UP` (Scrape cả 2 node web frontend)

---

### 3. Grafana Custom Dashboard (`monitoring-grafana-dashboard-server`)
1. Truy cập Grafana: `http://localhost:3000` (User: `admin` / Pass: `admin`)
2. Datasource `Prometheus` đã được cấu hình tự động.
3. Dashboard **"System Health of 21110001"** đã được nạp sẵn tự động với 3 Panel:
   - Panel 1: **CPU Utilization (%)**
   - Panel 2: **RAM Memory Usage (%)**
   - Panel 3: **Network Traffic (I/O)**

---

### 4. Keycloak Authentication & Identity Server (`authentication-identity-server`)
1. Truy cập Admin Console: `http://localhost:8081` (User: `admin` / Pass: `admin`)
2. Realm `realm_21110001`, Client `flask-app`, User `sv01` và `sv02` (Password: `password123`) đã được nạp tự động qua `--import-realm`.
3. Kiểm thử lấy Token qua CLI:
```bash
bash ./authentication-identity-server/test-token.sh
```

---

### 5. API Gateway Reverse Proxy & Load Balancer (`api-gateway-proxy-server`)
Kiểm tra tất cả luồng đi qua cổng 80:
- **Round Robin 2 Web Servers:** Gọi nhiều lần vào `http://localhost/` và quan sát header `X-Upstream-Backend` luân phiên giữa `172.28.0.11:80` và `172.28.0.12:80`.
  ```bash
  curl -i http://localhost/
  ```
- **Blog:** `http://localhost/blog/`
- **Route /student (Mở rộng 9):** `http://localhost/student/` hoặc `http://localhost/student`
- **API Backend:** `http://localhost/api/hello` và `http://localhost/api/students-db`
- **Keycloak qua Gateway:** `http://localhost/auth/`
---

### 6. MinIO Object Storage (`object-storage-server`)
1. **Truy cập MinIO Console:**
   - URL: `http://localhost:9001` (User: `minioadmin` / Pass: `minioadmin`)

2. **Tạo Bucket & Tải File:**
   - Vào mục **Buckets** -> Tạo 2 bucket: `profile-pics` và `documents`.
   - Mở bucket `profile-pics` và tải lên một hình ảnh bất kỳ (ví dụ: `images.png`).

3. **Cấu hình Anonymous Public Download cho bucket `profile-pics`:**
   - Do giao diện MinIO Console ẩn tính năng đổi quyền Public trực tiếp, thực hiện qua MinIO Client (`mc`) bên trong container:
   ```bash
   docker exec -it object-storage-server sh -c "mc alias set myminio http://localhost:9000 minioadmin minioadmin && mc anonymous set download myminio/profile-pics"
   ```

4. **Kiểm thử truy cập Public:**
   - Mở trình duyệt và truy cập trực tiếp URL file đã upload:
   ```
   http://localhost:9000/profile-pics/images.png
   ```
