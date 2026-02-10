# 🔍 Quick Railway Backend Status Checker

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   Checking Railway Backend Status" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$railwayUrl = "https://social-media-backend-production-8924.up.railway.app"

# Test 1: Check DNS resolution
Write-Host "Test 1: DNS Resolution" -ForegroundColor Yellow
Write-Host "   Testing: $railwayUrl" -ForegroundColor Gray
try {
    $dns = [System.Net.Dns]::GetHostAddresses("social-media-backend-production-8924.up.railway.app")
    Write-Host "   ✅ DNS Resolved to: $($dns[0].IPAddressToString)" -ForegroundColor Green
    $dnsOk = $true
} catch {
    Write-Host "   ❌ DNS Resolution Failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    $dnsOk = $false
}
Write-Host ""

# Test 2: Check if port is open
if ($dnsOk) {
    Write-Host "Test 2: Port Connectivity (HTTPS - Port 443)" -ForegroundColor Yellow
    try {
        $connection = Test-NetConnection -ComputerName "social-media-backend-production-8924.up.railway.app" -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($connection) {
            Write-Host "   ✅ Port 443 is OPEN" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Port 443 is CLOSED" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Connection Test Failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 3: Try to access the API
Write-Host "Test 3: API Accessibility" -ForegroundColor Yellow
Write-Host "   Testing: $railwayUrl/api/auth/signup" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "$railwayUrl/api/auth/signup" -Method Options -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   ✅ API is ACCESSIBLE!" -ForegroundColor Green
    Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
    $apiOk = $true
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "   ⚠️  API responded with status: $statusCode" -ForegroundColor Yellow
        $apiOk = $true
    } else {
        Write-Host "   ❌ API is NOT ACCESSIBLE!" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        $apiOk = $false
    }
}
Write-Host ""

# Test 4: Try signup endpoint
if ($apiOk) {
    Write-Host "Test 4: Signup Endpoint Test" -ForegroundColor Yellow
    $testUser = @{
        name = "Test User"
        email = "test$(Get-Random)@example.com"
        password = "test123"
    } | ConvertTo-Json
    
    try {
        $signupResponse = Invoke-RestMethod -Uri "$railwayUrl/api/auth/signup" -Method Post -Body $testUser -ContentType "application/json" -ErrorAction Stop
        Write-Host "   ✅ SIGNUP WORKS!" -ForegroundColor Green
        Write-Host "   Response: $($signupResponse | ConvertTo-Json)" -ForegroundColor Gray
    } catch {
        $errorResponse = $_.ErrorDetails.Message
        Write-Host "   ❌ Signup Failed" -ForegroundColor Red
        if ($errorResponse) {
            Write-Host "   Error: $errorResponse" -ForegroundColor Red
        } else {
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

# Summary
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSIS SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $dnsOk) {
    Write-Host "❌ BACKEND IS NOT DEPLOYED OR URL IS WRONG" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. Railway service was never deployed" -ForegroundColor White
    Write-Host "2. Railway service was deleted" -ForegroundColor White
    Write-Host "3. The URL is incorrect" -ForegroundColor White
    Write-Host ""
    Write-Host "SOLUTIONS:" -ForegroundColor Yellow
    Write-Host "→ Check Railway dashboard: https://railway.app/dashboard" -ForegroundColor White
    Write-Host "→ Verify the correct deployment URL" -ForegroundColor White
    Write-Host "→ Or run backend locally with: ./mvnw.cmd spring-boot:run" -ForegroundColor White
} elseif (-not $apiOk) {
    Write-Host "⚠️  BACKEND IS REACHABLE BUT NOT RESPONDING" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. Backend crashed or failed to start" -ForegroundColor White
    Write-Host "2. MongoDB connection issues" -ForegroundColor White
    Write-Host "3. Port configuration problems" -ForegroundColor White
    Write-Host ""
    Write-Host "SOLUTIONS:" -ForegroundColor Yellow
    Write-Host "→ Check Railway logs in the dashboard" -ForegroundColor White
    Write-Host "→ Redeploy with: .\fix-and-deploy.ps1" -ForegroundColor White
    Write-Host "→ Or run backend locally for testing" -ForegroundColor White
} else {
    Write-Host "✅ BACKEND IS RUNNING!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend is accessible and working." -ForegroundColor Green
    Write-Host "If signup still doesn't work from frontend, check:" -ForegroundColor Yellow
    Write-Host "→ Frontend .env file has correct URL" -ForegroundColor White
    Write-Host "→ Frontend dev server was restarted after .env change" -ForegroundColor White
    Write-Host "→ Browser console for CORS or network errors" -ForegroundColor White
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Offer to run local backend
Write-Host "Would you like to run the backend LOCALLY instead? (y/n)" -ForegroundColor Yellow
$runLocal = Read-Host
if ($runLocal -eq "y" -or $runLocal -eq "Y") {
    Write-Host ""
    Write-Host "Starting local backend on http://localhost:8080..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Don't forget to update frontend .env:" -ForegroundColor Yellow
    Write-Host "VITE_API_BASE_URL=http://localhost:8080/api" -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds 3
    & ./mvnw.cmd spring-boot:run
}
