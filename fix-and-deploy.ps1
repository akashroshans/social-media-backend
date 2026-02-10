# 🚀 Fix and Deploy Backend to Railway
# This script will prepare and deploy your backend

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   Social Media Backend - Fix and Deploy Script" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if we're in the right directory
$currentDir = Get-Location
if (-not (Test-Path "pom.xml")) {
    Write-Host "❌ ERROR: Not in backend project directory!" -ForegroundColor Red
    Write-Host "Please run this script from the backend project root." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Step 1: In correct directory" -ForegroundColor Green
Write-Host "   Location: $currentDir" -ForegroundColor Gray
Write-Host ""

# Step 2: Check if Maven wrapper exists
if (-not (Test-Path "mvnw.cmd")) {
    Write-Host "❌ ERROR: Maven wrapper not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Step 2: Maven wrapper found" -ForegroundColor Green
Write-Host ""

# Step 3: Clean and build the project
Write-Host "⚙️  Step 3: Building project..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

$buildOutput = & ./mvnw.cmd clean package -DskipTests 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host "Error output:" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Step 3: Build successful!" -ForegroundColor Green
Write-Host ""

# Step 4: Check if Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "⚙️  Step 4: Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✅ Git initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Step 4: Git repository already initialized" -ForegroundColor Green
}
Write-Host ""

# Step 5: Check Git status
Write-Host "⚙️  Step 5: Checking Git status..." -ForegroundColor Yellow
$gitStatus = git status --short
if ($gitStatus) {
    Write-Host "   Found uncommitted changes:" -ForegroundColor Gray
    Write-Host $gitStatus -ForegroundColor Gray
} else {
    Write-Host "   No uncommitted changes" -ForegroundColor Gray
}
Write-Host ""

# Step 6: Stage all changes
Write-Host "⚙️  Step 6: Staging changes..." -ForegroundColor Yellow
git add .
Write-Host "✅ Changes staged" -ForegroundColor Green
Write-Host ""

# Step 7: Commit changes
Write-Host "⚙️  Step 7: Committing changes..." -ForegroundColor Yellow
$commitMessage = "Fix CORS configuration and port settings for Railway deployment"
git commit -m $commitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Nothing to commit (already up to date)" -ForegroundColor Yellow
} else {
    Write-Host "✅ Changes committed" -ForegroundColor Green
}
Write-Host ""

# Step 8: Check remote repository
Write-Host "⚙️  Step 8: Checking Git remote..." -ForegroundColor Yellow
$remote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Remote repository configured:" -ForegroundColor Green
    Write-Host "   $remote" -ForegroundColor Gray
    Write-Host ""
    
    # Ask if user wants to push
    Write-Host "==============================================================" -ForegroundColor Cyan
    $push = Read-Host "Do you want to push to Railway now? (y/n)"
    if ($push -eq "y" -or $push -eq "Y") {
        Write-Host ""
        Write-Host "⚙️  Pushing to Railway..." -ForegroundColor Yellow
        git push origin main
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pushed to Railway!" -ForegroundColor Green
            Write-Host ""
            Write-Host "==============================================================" -ForegroundColor Cyan
            Write-Host "   Railway Deployment Started!" -ForegroundColor Green
            Write-Host "==============================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Yellow
            Write-Host "1. Go to Railway dashboard: https://railway.app/dashboard" -ForegroundColor White
            Write-Host "2. Wait 2-5 minutes for deployment to complete" -ForegroundColor White
            Write-Host "3. Check deployment logs for any errors" -ForegroundColor White
            Write-Host "4. Get the deployment URL from Settings > Public Networking" -ForegroundColor White
            Write-Host "5. Test the backend with test-deployment.ps1" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "❌ Push failed!" -ForegroundColor Red
            Write-Host "Please check your Git configuration and try again." -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "⚠️  Skipped pushing to Railway" -ForegroundColor Yellow
        Write-Host "Run 'git push origin main' manually when ready." -ForegroundColor Gray
    }
} else {
    Write-Host "❌ No remote repository configured!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To deploy to Railway:" -ForegroundColor Yellow
    Write-Host "1. Create a new project on Railway: https://railway.app" -ForegroundColor White
    Write-Host "2. Connect your GitHub repository" -ForegroundColor White
    Write-Host "3. Railway will auto-deploy on push" -ForegroundColor White
    Write-Host ""
    Write-Host "OR add Railway remote manually:" -ForegroundColor Yellow
    Write-Host "   git remote add origin <your-railway-git-url>" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   Script Complete!" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Step 9: Test local backend (optional)
Write-Host "Would you like to test the backend locally? (y/n)" -ForegroundColor Yellow
$testLocal = Read-Host
if ($testLocal -eq "y" -or $testLocal -eq "Y") {
    Write-Host ""
    Write-Host "⚙️  Starting local backend..." -ForegroundColor Yellow
    Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host ""
    & ./mvnw.cmd spring-boot:run
}
