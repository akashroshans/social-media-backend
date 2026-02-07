# 🚂 Railway Deployment Guide

## ✅ Backend Configuration Complete!

Your backend has been configured for Railway deployment with the following fixes:

### 🔧 Changes Made

1. **✅ CORS Configuration Added**
   - Allows frontend to connect from any origin
   - Supports all necessary HTTP methods (GET, POST, PUT, DELETE, OPTIONS)
   - Enables credentials for JWT authentication

2. **✅ Dynamic Port Configuration**
   - Server now uses `${PORT:8080}` 
   - Railway assigns port dynamically via environment variable
   - Falls back to 8080 for local development

3. **✅ Security Configuration Enhanced**
   - Added CORS configuration source
   - Proper headers and methods allowed
   - Credentials enabled for authentication

---

## 🚀 How to Deploy/Redeploy to Railway

### Step 1: Commit and Push Changes

```powershell
# Add all changes
git add .

# Commit with message
git commit -m "Add CORS configuration and dynamic port for Railway deployment"

# Push to your repository
git push origin main
```

### Step 2: Railway Will Auto-Deploy

If you have auto-deployment enabled, Railway will:
1. Detect the push
2. Rebuild your application
3. Deploy with new configuration
4. Restart the service

**OR manually trigger deployment:**
1. Go to Railway dashboard
2. Click on your backend service
3. Go to "Deployments" tab
4. Click "Deploy" or "Redeploy"

### Step 3: Verify Deployment

Check Railway logs for:
```
Started BackendApplication in X.XXX seconds
```

---

## 🧪 Test Backend Connection

### Test 1: Check if Backend is Alive

**In PowerShell:**
```powershell
curl https://social-media-backend-production-8924.up.railway.app/api/auth/signup -Method OPTIONS
```

You should see status `200 OK` with CORS headers.

### Test 2: Test Signup Endpoint

**In PowerShell:**
```powershell
$body = @{
    name = "Test User"
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://social-media-backend-production-8924.up.railway.app/api/auth/signup" -Method POST -Body $body -ContentType "application/json"
```

### Test 3: Browser Console Test

Open browser console and run:
```javascript
fetch('https://social-media-backend-production-8924.up.railway.app/api/auth/signup', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ 
    name: 'Test User', 
    email: 'test' + Date.now() + '@example.com', 
    password: 'test123' 
  })
})
.then(r => r.json())
.then(data => console.log('✅ Success:', data))
.catch(err => console.error('❌ Error:', err));
```

---

## 🔍 Railway Environment Variables (Optional)

You can configure these in Railway dashboard:

| Variable | Value | Description |
|----------|-------|-------------|
| `PORT` | Auto-set by Railway | Don't set manually |
| `MONGODB_URI` | Your MongoDB connection | Optional override |
| `JWT_SECRET` | Strong secret key | Recommended for production |

---

## 🐛 Troubleshooting

### Issue: CORS Errors Still Appearing

**Check:**
1. ✅ Backend redeployed with new code
2. ✅ Clear browser cache
3. ✅ Check Railway logs for startup errors
4. ✅ Verify the deployment is using latest commit

**Solution:**
```powershell
# Force rebuild and redeploy
git commit --allow-empty -m "Trigger Railway rebuild"
git push origin main
```

### Issue: Backend Not Starting

**Check Railway Logs for:**
- MongoDB connection errors
- Port binding issues
- Missing dependencies

**Common fixes:**
1. Verify MongoDB connection string is correct
2. Check if MongoDB Atlas allows Railway IP addresses
3. Ensure `pom.xml` has all dependencies

### Issue: Cannot Connect to MongoDB

**MongoDB Atlas Configuration:**
1. Go to MongoDB Atlas dashboard
2. Navigate to "Network Access"
3. Add IP address: `0.0.0.0/0` (Allow from anywhere)
   - Or get Railway's outbound IPs and whitelist them
4. Save changes

### Issue: File Uploads Not Working

**Railway Ephemeral Storage:**
- Railway uses ephemeral file storage
- Uploaded files are lost on redeployment
- **Solution:** Use cloud storage (AWS S3, Cloudinary, etc.)

**For testing purposes:**
- Current setup works, but files reset on each deployment

---

## 📝 Production Checklist

Before going to production:

### Security

- [ ] **Update CORS Origins**
  - Edit `SecurityConfig.java`
  - Replace `setAllowedOriginPatterns(Arrays.asList("*"))` with specific frontend URLs
  ```java
  configuration.setAllowedOrigins(Arrays.asList(
      "https://your-frontend-domain.com",
      "https://www.your-frontend-domain.com"
  ));
  ```

- [ ] **Set JWT Secret via Environment Variable**
  - In Railway dashboard, add variable: `JWT_SECRET`
  - Update `application.properties`:
  ```properties
  jwt.secret=${JWT_SECRET:mySecretKeyForJWTTokenGenerationAndValidationPleaseChangeInProduction}
  ```

- [ ] **Use Cloud Storage for Files**
  - Integrate AWS S3, Cloudinary, or similar
  - Update `FileStorageService.java`

- [ ] **Enable HTTPS Only**
  - Railway provides HTTPS by default
  - Ensure your frontend uses `https://` URLs

### MongoDB

- [ ] **Restrict Network Access**
  - Remove `0.0.0.0/0` if possible
  - Add specific Railway IPs

- [ ] **Use Strong Database Password**
  - Rotate credentials periodically

### Monitoring

- [ ] **Set up Railway Alerts**
  - Configure deployment notifications
  - Set up error monitoring

- [ ] **Check Railway Logs Regularly**
  - Monitor for errors
  - Check performance metrics

---

## 🌐 Frontend Configuration

Your frontend should use:

### Environment Variables (`.env`)

```env
VITE_API_BASE_URL=https://social-media-backend-production-8924.up.railway.app/api
```

### Restart Frontend After Backend Changes

```bash
# Stop dev server (Ctrl+C)
# Then restart:
npm run dev
```

---

## 🎯 Current Deployment URL

**Backend Base URL:**
```
https://social-media-backend-production-8924.up.railway.app
```

**API Endpoints:**
```
https://social-media-backend-production-8924.up.railway.app/api/auth/signup
https://social-media-backend-production-8924.up.railway.app/api/auth/login
https://social-media-backend-production-8924.up.railway.app/api/posts
https://social-media-backend-production-8924.up.railway.app/api/users/me
```

---

## 🔄 Continuous Deployment

### Automatic Deployment

Every time you push to `main` branch:
1. Railway detects changes
2. Runs Maven build
3. Creates new deployment
4. Routes traffic to new version

### Manual Deployment

1. Go to Railway dashboard
2. Select your service
3. Click "Deployments"
4. Click "Deploy Latest"

---

## 📊 Monitoring Your Deployment

### Railway Dashboard

**Check:**
- ✅ Deployment status (Active/Failed)
- ✅ Build logs
- ✅ Runtime logs
- ✅ Metrics (CPU, Memory, Network)

### Application Logs

Look for these success indicators:
```
✅ Started BackendApplication in X.XXX seconds
✅ MongoDB connection successful
✅ Tomcat started on port(s): XXXX
```

Look out for errors:
```
❌ MongoTimeoutException
❌ BindException: Address already in use
❌ ClassNotFoundException
```

---

## 🎉 Next Steps

1. **Commit and push changes** to trigger redeployment
2. **Wait for Railway to complete deployment** (~2-3 minutes)
3. **Test backend connection** using the tests above
4. **Connect your frontend** and test end-to-end
5. **Create your first post** and verify everything works!

---

## 🆘 Quick Reference

### Useful Commands

```powershell
# Build locally
.\mvnw clean package

# Run locally
.\mvnw spring-boot:run

# Check if running locally
curl http://localhost:8080/api/auth/signup -Method OPTIONS

# Test Railway deployment
curl https://social-media-backend-production-8924.up.railway.app/api/auth/signup -Method OPTIONS

# Git commands
git add .
git commit -m "Your message"
git push origin main
```

### Important URLs

- **Railway Dashboard:** https://railway.app/dashboard
- **MongoDB Atlas:** https://cloud.mongodb.com/
- **Backend URL:** https://social-media-backend-production-8924.up.railway.app
- **API Base:** https://social-media-backend-production-8924.up.railway.app/api

---

**Ready to Deploy! 🚀**

Run the git commands above to push your changes and Railway will handle the rest!
