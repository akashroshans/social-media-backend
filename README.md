# Social Media Backend API

A minimal Spring Boot REST API for a social media platform with user authentication, profiles, and posts featuring actual file upload capabilities.

## 🚀 Live Deployment

**Production URL:** https://social-media-backend-production-8924.up.railway.app/api

Status: ✅ Deployed on Railway

## Tech Stack

- **Java 21 (LTS)**
- **Spring Boot 4.0.2**
- **MongoDB Atlas**
- **Spring Security + JWT**
- **File Storage (MultipartFile)**
- **Lombok**
- **Maven 3.9+**

## Prerequisites

- Java 17+
- Maven 3.9+
- MongoDB Atlas account (or local MongoDB 4.4+ on `localhost:27017`)

## Quick Start

### Option 1: Use Deployed Backend (Recommended)

Your backend is already deployed! Just use:
```
https://social-media-backend-production-8924.up.railway.app/api
```

### Option 2: Run Locally

1. **Clone and configure**
   ```bash
   git clone <your-repo>
   cd social-media-backend
   ```

2. **Update MongoDB connection** (optional - uses Atlas by default)
   Edit `src/main/resources/application.properties`

3. **Build and run**
   ```bash
   mvnw clean install
   mvnw spring-boot:run
   ```

Server starts at: `http://localhost:8080`

## 📦 Deployment

### Deploy to Railway

1. **Commit your changes**
   ```bash
   git add .
   git commit -m "Update configuration"
   git push origin main
   ```

2. **Railway auto-deploys** (if configured)
   - Or manually trigger from Railway dashboard

3. **Test deployment**
   ```powershell
   .\test-deployment.ps1
   ```

See [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) for detailed instructions.

## Configuration

`src/main/resources/application.properties`:
```properties
# MongoDB Atlas (Cloud)
spring.data.mongodb.uri=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority

# OR Local MongoDB
# spring.data.mongodb.uri=mongodb://localhost:27017/social_db

jwt.secret=your-secret-key-minimum-256-bits-for-HS256
jwt.expiration=86400000
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=uploads
```

**Current Configuration:**
- MongoDB Atlas: `mongodb+srv://jeswinrooks_db_user:rooks@cluster2.qla5vms.mongodb.net/social_db`
- Database: `social_db`
- Upload Directory: `uploads/`

## API Endpoints

### Authentication

#### Signup
```http
POST /api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "User registered successfully!",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "bio": null,
    "profilePicture": null
  }
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Login successful!",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

### User Profile (Requires Authentication)

#### Get Profile
```http
GET /api/users/me
Authorization: Bearer <token>
```

#### Update Profile
```http
PUT /api/users/me
Authorization: Bearer <token>
Content-Type: multipart/form-data

bio: "Software developer and coffee enthusiast"
profilePicture: <file>
```

**Response:**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "bio": "Software developer and coffee enthusiast",
    "profilePicture": "a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg"
  }
}
```

#### Get Profile Picture
```http
GET /api/users/profile-pictures/{fileName}
```

### Posts (Requires Authentication)

#### Create Post
```http
POST /api/posts
Authorization: Bearer <token>
Content-Type: multipart/form-data

contentText: "Check out this amazing sunset!"
image: <file>
```

**Response:**
```json
{
  "message": "Post created successfully!",
  "post": {
    "id": "507f1f77bcf86cd799439012",
    "contentText": "Check out this amazing sunset!",
    "imageFileName": "b2c3d4e5-f6g7-8901-bcde-fg2345678901.jpg",
    "createdAt": "2024-01-15T10:30:00",
    "userId": "507f1f77bcf86cd799439011",
    "userName": "John Doe",
    "userProfilePicture": "a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg"
  }
}
```

#### Get All Posts (Feed)
```http
GET /api/posts
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "507f1f77bcf86cd799439012",
    "contentText": "Check out this amazing sunset!",
    "imageFileName": "b2c3d4e5-f6g7-8901-bcde-fg2345678901.jpg",
    "createdAt": "2024-01-15T10:30:00",
    "userId": "507f1f77bcf86cd799439011",
    "userName": "John Doe",
    "userProfilePicture": "a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg"
  }
]
```

#### Get Post Image
```http
GET /api/posts/images/{fileName}
```

#### Delete Post
```http
DELETE /api/posts/{postId}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Post deleted successfully"
}
```

## Testing with cURL

### Signup
```bash
curl -X POST http://localhost:8081/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","password":"password123"}'
```

### Login
```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'
```

### Create Post with Image
```bash
curl -X POST http://localhost:8081/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "contentText=Amazing sunset!" \
  -F "image=@/path/to/image.jpg"
```

### Update Profile with Picture
```bash
curl -X PUT http://localhost:8081/api/users/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "bio=Software developer" \
  -F "profilePicture=@/path/to/profile.jpg"
```

### Get Feed
```bash
curl -X GET http://localhost:8081/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## File Upload

- **Supported formats:** JPG, PNG, GIF (any file extension)
- **Max file size:** 10MB
- **Storage location:** `uploads/` directory
- **File naming:** UUID-based (e.g., `a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg`)
- **Access:** Public URLs for images via GET endpoints

## Project Structure

```
Backend/
├── src/main/java/com/rooks/social_media/backend/
│   ├── config/
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── JwtUtil.java
│   │   └── SecurityConfig.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   ├── PostController.java
│   │   └── UserController.java
│   ├── entity/
│   │   ├── Post.java
│   │   └── User.java
│   ├── repository/
│   │   ├── PostRepository.java
│   │   └── UserRepository.java
│   ├── service/
│   │   ├── FileStorageService.java
│   │   ├── PostService.java
│   │   └── UserService.java
│   └── BackendApplication.java
├── src/main/resources/
│   └── application.properties
└── pom.xml
```

## MongoDB Collections

### users
```json
{
  "_id": "ObjectId",
  "name": "String",
  "email": "String (unique)",
  "password": "String (BCrypt)",
  "bio": "String",
  "profilePicture": "String (filename)",
  "postIds": ["String"]
}
```

### posts
```json
{
  "_id": "ObjectId",
  "contentText": "String",
  "imageFileName": "String",
  "createdAt": "LocalDateTime",
  "userId": "String",
  "userName": "String",
  "userProfilePicture": "String"
}
```

## Security

- **Password Encryption:** BCrypt
- **Authentication:** JWT (JSON Web Tokens)
- **Token Expiration:** 24 hours
- **Stateless Sessions:** No server-side session storage
- **Authorization Header:** `Bearer <token>`

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200 OK` - Success
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Invalid credentials or missing token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

Example error response:
```json
{
  "error": "Email already exists"
}
```

## Development Notes

- **File Storage:** Files stored in filesystem, not database
- **Image Serving:** Direct file access via Resource/UrlResource
- **Post Deletion:** Automatically removes associated image file
- **Profile Update:** Automatically removes old profile picture when uploading new one
- **Denormalized Data:** Posts contain user info (userId, userName, userProfilePicture) for efficient queries
- **Database:** MongoDB with no complex relationships, using document references

## License

MIT
