# Quick Fix cho lỗi khi chạy ứng dụng

## Vấn đề phổ biến và cách sửa

### 1. Lỗi: "Process terminated with exit code: 1"

**Nguyên nhân có thể:**
- MongoDB chưa chạy
- Port 8080 đã được sử dụng
- Lỗi cấu hình JSP

**Cách kiểm tra:**

1. **Kiểm tra MongoDB:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 27017
   ```
   Nếu không kết nối được, khởi động MongoDB trước.

2. **Kiểm tra port 8080:**
   ```powershell
   netstat -ano | findstr :8080
   ```
   Nếu port đã được sử dụng, đổi port trong `application.properties`:
   ```
   server.port=8081
   ```

3. **Chạy với log đầy đủ:**
   ```powershell
   mvn spring-boot:run -X
   ```
   Hoặc:
   ```powershell
   mvn spring-boot:run -e
   ```

### 2. Lỗi JSP không tìm thấy

Spring Boot 3.x với JAR packaging có thể gặp vấn đề với JSP. 

**Giải pháp tạm thời - Test không cần MongoDB:**

Sửa `application.properties`, comment dòng MongoDB:
```properties
# spring.data.mongodb.uri=mongodb://localhost:27017/chatdb
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration
```

**Lưu ý:** Với cấu hình này, ứng dụng sẽ chạy nhưng không lưu dữ liệu vào MongoDB.

### 3. Chạy trực tiếp JAR file

```powershell
mvn clean package -DskipTests
java -jar target/chat-realtime-1.0.0.jar
```

### 4. Kiểm tra Java version

```powershell
java -version
```
Phải là Java 17 hoặc cao hơn.

### 5. Xem log đầy đủ

Thêm vào `application.properties`:
```properties
logging.level.root=INFO
logging.level.com.example.chat=DEBUG
```

Sau đó chạy:
```powershell
mvn spring-boot:run
```

## Test nhanh không cần MongoDB

Nếu chỉ muốn test WebSocket và UI, có thể tạm thời disable MongoDB:

1. Sửa `application.properties`:
   ```properties
   # spring.data.mongodb.uri=mongodb://localhost:27017/chatdb
   spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration
   ```

2. Sửa `DataInitializer.java` để không chạy khi không có MongoDB:
   ```java
   @Override
   public void run(String... args) {
       try {
           if (roomService.findAll().isEmpty()) {
               log.info("Initializing default rooms...");
               roomService.createRoom("General", "Phòng chat chung cho mọi người");
               roomService.createRoom("Tech", "Thảo luận về công nghệ");
               roomService.createRoom("Random", "Chat tự do về mọi chủ đề");
               log.info("Default rooms created successfully!");
           }
       } catch (Exception e) {
           log.warn("Could not initialize rooms: " + e.getMessage());
       }
   }
   ```

## Liên hệ

Nếu vẫn gặp lỗi, vui lòng cung cấp:
1. Full error message từ console
2. Java version (`java -version`)
3. MongoDB status
4. Output của `mvn spring-boot:run -e`

