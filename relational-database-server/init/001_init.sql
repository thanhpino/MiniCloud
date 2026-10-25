-- Database 1: minicloud (Cơ bản)
CREATE DATABASE IF NOT EXISTS minicloud;
USE minicloud;

CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO notes (title, content) VALUES
('Welcome to MiniCloud', 'Hệ thống điện toán đám mây thu nhỏ MiniCloud.'),
('Task A', 'Hoàn thiện Infra, Security & Monitoring.'),
('Task B', 'Hoàn thiện Application, Database & Storage.');

-- Database 2: studentdb (Mở rộng 3)
CREATE DATABASE IF NOT EXISTS studentdb;
USE studentdb;

CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    class_name VARCHAR(50),
    gpa DECIMAL(3, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (student_id, full_name, email, class_name, gpa) VALUES
('524H0032', 'Trương Minh Thành', 'thanh.truong@cloud.local', '24h502023', 4.00),
('524H0125', 'Trương Cao Sang', 'sang.truong@cloud.local', '24h50203', 3.85),
('21110001', 'Nguyễn Văn An', 'an.nguyen@cloud.local', '21DTHA1', 3.65),
('21110002', 'Trần Thị Bình', 'binh.tran@cloud.local', '21DTHA1', 3.80),
('21110003', 'Lê Hoàng Cường', 'cuong.le@cloud.local', '21DTHA2', 3.50);
-- Grant privileges for minicloud_user
GRANT ALL PRIVILEGES ON minicloud.* TO 'minicloud_user'@'%';
GRANT ALL PRIVILEGES ON studentdb.* TO 'minicloud_user'@'%';
FLUSH PRIVILEGES;
