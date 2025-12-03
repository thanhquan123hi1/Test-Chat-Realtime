<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Realtime</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .chat-container {
            width: 90%;
            max-width: 800px;
            height: 90vh;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .chat-header h1 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .user-info {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
            padding: 10px;
            background: #f5f5f5;
            border-radius: 5px;
        }
        
        .user-info input {
            flex: 1;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .room-selector {
            padding: 10px;
            background: #f5f5f5;
            border-bottom: 1px solid #ddd;
        }
        
        .room-selector select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            background: white;
        }
        
        .messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f9f9f9;
        }
        
        .message {
            margin-bottom: 15px;
            padding: 10px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .message-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 12px;
            color: #666;
        }
        
        .message-sender {
            font-weight: bold;
            color: #667eea;
        }
        
        .message-content {
            color: #333;
            line-height: 1.5;
        }
        
        .input-container {
            padding: 15px;
            background: white;
            border-top: 1px solid #ddd;
            display: flex;
            gap: 10px;
        }
        
        .input-container input {
            flex: 1;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .input-container button {
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: transform 0.2s;
        }
        
        .input-container button:hover {
            transform: scale(1.05);
        }
        
        .input-container button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .status {
            padding: 10px;
            text-align: center;
            font-size: 12px;
            color: #666;
            background: #f5f5f5;
        }
        
        .status.connected {
            color: #4caf50;
            background: #e8f5e9;
        }
        
        .status.disconnected {
            color: #f44336;
            background: #ffebee;
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            <h1>💬 Chat Realtime</h1>
        </div>
        
        <div class="user-info">
            <input type="text" id="usernameInput" placeholder="Nhập username của bạn..." value="User1">
        </div>
        
        <div class="room-selector">
            <select id="roomSelect">
                <option value="">-- Chọn Room --</option>
            </select>
        </div>
        
        <div class="status disconnected" id="status">Chưa kết nối</div>
        
        <div class="messages-container" id="messagesContainer">
            <div style="text-align: center; color: #999; padding: 20px;">
                Chọn một room để bắt đầu chat
            </div>
        </div>
        
        <div class="input-container">
            <input type="text" id="messageInput" placeholder="Nhập tin nhắn..." disabled>
            <button id="sendButton" disabled>Gửi</button>
        </div>
    </div>

    <!-- SockJS and STOMP.js from CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@stomp/stompjs@7/bundles/stomp.umd.min.js"></script>

    <script>
        let stompClient = null;
        let currentRoomId = null;
        let currentUserId = null;
        let rooms = [];

        // Khởi tạo
        document.addEventListener('DOMContentLoaded', function() {
            loadRooms();
            
            document.getElementById('sendButton').addEventListener('click', sendMessage);
            document.getElementById('messageInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });
            
            document.getElementById('roomSelect').addEventListener('change', function() {
                const roomId = this.value;
                if (roomId) {
                    changeRoom(roomId);
                }
            });
        });

        // Load danh sách rooms
        async function loadRooms() {
            try {
                const response = await fetch('/api/rooms');
                rooms = await response.json();
                
                const select = document.getElementById('roomSelect');
                select.innerHTML = '<option value="">-- Chọn Room --</option>';
                
                rooms.forEach(room => {
                    const option = document.createElement('option');
                    option.value = room.id;
                    option.textContent = room.name + (room.description ? ' - ' + room.description : '');
                    select.appendChild(option);
                });
            } catch (error) {
                console.error('Error loading rooms:', error);
            }
        }

        // Kết nối WebSocket
        function connect() {
            const socket = new SockJS('/ws');
            stompClient = new StompJs.Client({
                webSocketFactory: () => socket,
                debug: function(str) {
                    console.log(str);
                },
                reconnectDelay: 5000,
                heartbeatIncoming: 4000,
                heartbeatOutgoing: 4000,
            });

            stompClient.onConnect = function(frame) {
                console.log('Connected: ' + frame);
                updateStatus(true);
                
                if (currentRoomId) {
                    subscribeToRoom(currentRoomId);
                }
            };

            stompClient.onStompError = function(frame) {
                console.error('Broker reported error: ' + frame.headers['message']);
                console.error('Additional details: ' + frame.body);
                updateStatus(false);
            };

            stompClient.onDisconnect = function() {
                console.log('Disconnected');
                updateStatus(false);
            };

            stompClient.activate();
        }

        // Subscribe tới room
        function subscribeToRoom(roomId) {
            if (stompClient && stompClient.connected) {
                const topic = '/topic/rooms/' + roomId;
                stompClient.subscribe(topic, function(message) {
                    const chatMessage = JSON.parse(message.body);
                    displayMessage(chatMessage);
                });
                console.log('Subscribed to: ' + topic);
            }
        }

        // Đổi room
        async function changeRoom(roomId) {
            // Disconnect room cũ
            if (stompClient && stompClient.connected) {
                stompClient.deactivate();
            }
            
            currentRoomId = roomId;
            
            // Lấy username và tạo/get user
            const username = document.getElementById('usernameInput').value || 'Anonymous';
            try {
                const response = await fetch('/api/users/create?username=' + encodeURIComponent(username), {
                    method: 'POST'
                });
                const user = await response.json();
                currentUserId = user.id;
            } catch (error) {
                console.error('Error creating user:', error);
                // Fallback: tạo user tạm
                currentUserId = 'temp_' + Date.now();
            }
            
            // Load message history
            await loadMessageHistory(roomId);
            
            // Kết nối WebSocket và subscribe
            connect();
            
            // Enable input
            document.getElementById('messageInput').disabled = false;
            document.getElementById('sendButton').disabled = false;
        }

        // Load lịch sử tin nhắn
        async function loadMessageHistory(roomId) {
            try {
                const response = await fetch('/api/rooms/' + roomId + '/messages');
                const messages = await response.json();
                
                const container = document.getElementById('messagesContainer');
                container.innerHTML = '';
                
                // Hiển thị messages từ cũ đến mới
                messages.reverse().forEach(msg => {
                    displayMessage(msg);
                });
            } catch (error) {
                console.error('Error loading message history:', error);
            }
        }

        // Gửi message
        function sendMessage() {
            const input = document.getElementById('messageInput');
            const content = input.value.trim();
            
            if (!content || !currentRoomId || !stompClient || !stompClient.connected) {
                return;
            }
            
            const chatMessage = {
                senderId: currentUserId,
                senderName: document.getElementById('usernameInput').value || 'Anonymous',
                roomId: currentRoomId,
                content: content,
                timestamp: new Date().toISOString()
            };
            
            stompClient.publish({
                destination: '/app/chat.sendMessage',
                body: JSON.stringify(chatMessage)
            });
            
            input.value = '';
        }

        // Hiển thị message
        function displayMessage(message) {
            const container = document.getElementById('messagesContainer');
            
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message';
            
            const timestamp = new Date(message.timestamp).toLocaleString('vi-VN');
            
            // Sử dụng string concatenation thay vì template literal để tránh JSP parse ${} như EL
            messageDiv.innerHTML = 
                '<div class="message-header">' +
                    '<span class="message-sender">' + escapeHtml(message.senderName) + '</span>' +
                    '<span>' + timestamp + '</span>' +
                '</div>' +
                '<div class="message-content">' + escapeHtml(message.content) + '</div>';
            
            container.appendChild(messageDiv);
            container.scrollTop = container.scrollHeight;
        }

        // Update status
        function updateStatus(connected) {
            const statusDiv = document.getElementById('status');
            if (connected) {
                statusDiv.textContent = '✓ Đã kết nối';
                statusDiv.className = 'status connected';
            } else {
                statusDiv.textContent = '✗ Chưa kết nối';
                statusDiv.className = 'status disconnected';
            }
        }

        // Escape HTML để tránh XSS
        function escapeHtml(text) {
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, m => map[m]);
        }
    </script>
</body>
</html>

