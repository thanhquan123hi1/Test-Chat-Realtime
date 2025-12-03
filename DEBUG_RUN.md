# Cách debug lỗi khi chạy ứng dụng

## Bước 1: Xem log đầy đủ

Chạy lệnh sau để xem toàn bộ log:
```powershell
mvn spring-boot:run -X 2>&1 | Tee-Object -FilePath run.log
```

Hoặc đơn giản hơn:
```powershell
mvn spring-boot:run > run.log 2>&1
```

Sau đó mở file `run.log` để xem lỗi chi tiết.

## Bước 2: Kiểm tra các vấn đề phổ biến

### 1. MongoDB không chạy

**Kiểm tra:**
```powershell
Test-NetConnection -ComputerName localhost -Port 27017
```

**Nếu MongoDB chưa chạy:**
- Khởi động MongoDB service
- Hoặc tạm thời disable MongoDB (xem QUICK_FIX.md)

### 2. Port 8080 đã được sử dụng

**Kiểm tra:**
```powershell
netstat -ano | findstr :8080
```

**Giải pháp:**
- Đổi port trong `application.properties`: `server.port=8081`
- Hoặc kill process đang dùng port 8080

### 3. Java version không đúng

**Kiểm tra:**
```powershell
java -version
mvn -version
```

Phải là Java 17 hoặc cao hơn.

## Bước 3: Chạy với exception handling tốt hơn

Đã cập nhật `DataInitializer` để không crash khi MongoDB không kết nối được.

## Bước 4: Test từng phần

### Test chỉ compile:
```powershell
mvn clean compile
```

### Test build JAR:
```powershell
mvn clean package -DskipTests
```

### Test chạy JAR:
```powershell
java -jar target/chat-realtime-1.0.0.jar
```

## Bước 5: Xem log trong console

Khi chạy `mvn spring-boot:run`, bạn sẽ thấy:
- `Started ChatApplication in X.XXX seconds` - thành công
- Hoặc error message cụ thể - cần xem để biết lỗi gì

## Lỗi thường gặp và giải pháp

### "Cannot connect to MongoDB"
→ Khởi động MongoDB hoặc disable MongoDB tạm thời

### "Port 8080 already in use"
→ Đổi port hoặc kill process

### "JSP not found" hoặc "View not found"
→ Kiểm tra file `chat.jsp` có trong `src/main/webapp/WEB-INF/views/` không

### "ClassNotFoundException"
→ Chạy `mvn clean install` để rebuild

## Liên hệ

Nếu vẫn gặp lỗi, vui lòng cung cấp:
1. **Full error message** từ console hoặc file `run.log`
2. **Java version**: `java -version`
3. **Maven version**: `mvn -version`
4. **MongoDB status**: Đã chạy chưa?
5. **Output của**: `mvn spring-boot:run -e`

