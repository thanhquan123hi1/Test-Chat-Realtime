#!/bin/bash
# Bash script để test API endpoints (cho Linux/Mac)

echo "=== Testing Chat Realtime API ==="
echo ""

# Test 1: Get all rooms
echo "1. Testing GET /api/rooms"
ROOMS_RESPONSE=$(curl -s http://localhost:8080/api/rooms)
if [ $? -eq 0 ]; then
    echo "   Success! Rooms retrieved"
    echo "$ROOMS_RESPONSE" | grep -o '"name":"[^"]*"' | head -3
    FIRST_ROOM_ID=$(echo "$ROOMS_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
else
    echo "   Error: Could not connect to server"
    FIRST_ROOM_ID=""
fi
echo ""

# Test 2: Create user
echo "2. Testing POST /api/users/create"
RANDOM_USER="TestUser$RANDOM"
USER_RESPONSE=$(curl -s -X POST "http://localhost:8080/api/users/create?username=$RANDOM_USER")
if [ $? -eq 0 ]; then
    echo "   Success! Created user: $RANDOM_USER"
    USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
else
    echo "   Error: Could not create user"
    USER_ID=""
fi
echo ""

# Test 3: Get messages (if we have a room)
if [ ! -z "$FIRST_ROOM_ID" ]; then
    echo "3. Testing GET /api/rooms/$FIRST_ROOM_ID/messages"
    MESSAGES_RESPONSE=$(curl -s "http://localhost:8080/api/rooms/$FIRST_ROOM_ID/messages")
    if [ $? -eq 0 ]; then
        MESSAGE_COUNT=$(echo "$MESSAGES_RESPONSE" | grep -o '"content"' | wc -l)
        echo "   Success! Found $MESSAGE_COUNT messages"
    else
        echo "   Error: Could not retrieve messages"
    fi
    echo ""
fi

echo "=== Test Complete ==="
echo ""
echo "To test WebSocket, open http://localhost:8080 in your browser"
echo "Open multiple tabs to test realtime chat!"

