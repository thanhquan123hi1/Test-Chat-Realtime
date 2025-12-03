# PowerShell script để test API endpoints

Write-Host "=== Testing Chat Realtime API ===" -ForegroundColor Green
Write-Host ""

# Test 1: Get all rooms
Write-Host "1. Testing GET /api/rooms" -ForegroundColor Yellow
try {
    $rooms = Invoke-RestMethod -Uri "http://localhost:8080/api/rooms" -Method Get
    Write-Host "   Success! Found $($rooms.Count) rooms" -ForegroundColor Green
    $rooms | ForEach-Object {
        Write-Host "   - $($_.name): $($_.description) (ID: $($_.id))" -ForegroundColor Cyan
    }
    $firstRoomId = $rooms[0].id
}
catch {
    Write-Host "   Error: $_" -ForegroundColor Red
    $firstRoomId = $null
}
Write-Host ""

# Test 2: Create user
Write-Host "2. Testing POST /api/users/create" -ForegroundColor Yellow
try {
    $user = Invoke-RestMethod -Uri "http://localhost:8080/api/users/create?username=TestUser$(Get-Random)" -Method Post
    Write-Host "   Success! Created user: $($user.username) (ID: $($user.id))" -ForegroundColor Green
    $userId = $user.id
}
catch {
    Write-Host "   Error: $_" -ForegroundColor Red
    $userId = $null
}
Write-Host ""

# Test 3: Get messages (if we have a room)
if ($firstRoomId) {
    Write-Host "3. Testing GET /api/rooms/$firstRoomId/messages" -ForegroundColor Yellow
    try {
        $messages = Invoke-RestMethod -Uri "http://localhost:8080/api/rooms/$firstRoomId/messages" -Method Get
        Write-Host "   Success! Found $($messages.Count) messages" -ForegroundColor Green
        if ($messages.Count -gt 0) {
            Write-Host "   Latest message: $($messages[0].content) by $($messages[0].senderName)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "   Error: $_" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "=== Test Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "To test WebSocket, open http://localhost:8080 in your browser" -ForegroundColor Yellow
Write-Host "Open multiple tabs to test realtime chat!" -ForegroundColor Yellow

