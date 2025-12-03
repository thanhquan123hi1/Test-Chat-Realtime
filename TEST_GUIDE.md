# Hướng dẫn Test Chat Realtime Application

## Yêu cầu trước khi test

1. **MongoDB phải đang chạy**

   - MongoDB cần chạy tại `localhost:27017`
   - Nếu MongoDB chạy ở port khác, sửa file `src/main/resources/application.properties`

2. **Java 17** đã được cài đặt

3. **Maven** đã được cài đặt

## Các bước test

### Bước 1: Kiểm tra MongoDB

Kiểm tra MongoDB có đang chạy không:

```bash
# Windows PowerShell
Test-NetConnection -ComputerName localhost -Port 27017

# Hoặc mở MongoDB Compass và kết nối tới mongodb://localhost:27017
```

### Bước 2: Chạy ứng dụng

```bash
mvn spring-boot:run
```

Hoặc nếu muốn build JAR trước:

```bash
mvn clean package
java -jar target/chat-realtime-1.0.0.jar
```

Ứng dụng sẽ chạy tại: **http://localhost:8080**

### Bước 3: Test Chat Realtime

1. **Mở trình duyệt** và truy cập: `http://localhost:8080`

2. **Mở thêm 1-2 tab/window khác** cùng URL để mô phỏng nhiều người dùng

3. **Trong mỗi tab:**

   - Nhập username (ví dụ: "User1", "User2", "User3")
   - Chọn một room từ dropdown (General, Tech, hoặc Random)
   - Đợi kết nối WebSocket (status sẽ hiển thị "✓ Đã kết nối")

4. **Gửi tin nhắn:**

   - Nhập tin nhắn vào ô input
   - Nhấn Enter hoặc nút "Gửi"
   - Tin nhắn sẽ xuất hiện ngay lập tức trong TẤT CẢ các tab đang ở cùng room

5. **Test chuyển room:**
   - Chọn room khác từ dropdown
   - Lịch sử 20 tin nhắn gần nhất sẽ được load
   - Tin nhắn mới chỉ hiển thị trong room hiện tại

### Bước 4: Kiểm tra MongoDB

Kiểm tra dữ liệu đã được lưu vào MongoDB:

```bash
# Sử dụng MongoDB Shell (mongosh)
mongosh mongodb://localhost:27017/chatdb

# Xem các collections
show collections

# Xem users
db.users.find().pretty()

# Xem rooms
db.rooms.find().pretty()

# Xem messages
db.messages.find().pretty()

# Xem messages của một room cụ thể
db.messages.find({roomId: "ROOM_ID_HERE"}).sort({createdAt: -1}).limit(10)
```

## Test API Endpoints

### 1. Lấy danh sách rooms

```bash
curl http://localhost:8080/api/rooms
```

### 2. Lấy messages của một room

```bash
curl http://localhost:8080/api/rooms/{roomId}/messages
```

### 3. Tạo user

```bash
curl -X POST "http://localhost:8080/api/users/create?username=TestUser"
```

## Test WebSocket Connection

Sử dụng browser console để test WebSocket:

1. Mở Developer Tools (F12)
2. Vào tab Console
3. Chạy các lệnh sau:

```javascript
// Kết nối WebSocket
const socket = new SockJS("http://localhost:8080/ws");
const stompClient = StompJs.Stomp.over(socket);

stompClient.connect({}, function (frame) {
  console.log("Connected: " + frame);

  // Subscribe tới một room
  stompClient.subscribe("/topic/rooms/ROOM_ID", function (message) {
    console.log("Received:", JSON.parse(message.body));
  });

  // Gửi message
  stompClient.send(
    "/app/chat.sendMessage",
    {},
    JSON.stringify({
      senderId: "test-user-id",
      senderName: "Test User",
      roomId: "ROOM_ID",
      content: "Hello from console!",
      timestamp: new Date().toISOString(),
    })
  );
});
```

## Troubleshooting

### Lỗi: "Cannot connect to MongoDB"

- Kiểm tra MongoDB có đang chạy không
- Kiểm tra connection string trong `application.properties`
- Thử kết nối bằng MongoDB Compass

### Lỗi: "WebSocket connection failed"

- Kiểm tra server có đang chạy không
- Kiểm tra firewall không chặn port 8080
- Thử refresh trang

### Không thấy rooms trong dropdown

- Kiểm tra console log khi start ứng dụng
- Kiểm tra MongoDB có collection "rooms" không
- Restart ứng dụng để DataInitializer chạy lại

### Tin nhắn không hiển thị realtime

- Kiểm tra WebSocket connection status (phải là "✓ Đã kết nối")
- Kiểm tra cả 2 tab đang ở cùng room không
- Mở Developer Tools > Network > WS để xem WebSocket connection

## Expected Behavior

✅ Khi gửi tin nhắn trong tab 1, tin nhắn xuất hiện ngay trong tab 2 (nếu cùng room)
✅ Tin nhắn được lưu vào MongoDB
✅ Khi refresh trang, lịch sử 20 tin nhắn gần nhất được load
✅ Mỗi room có lịch sử tin nhắn riêng
✅ Username hiển thị đúng với người gửi
