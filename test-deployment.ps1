# Railway Backend Deployment Test Script
# Tests if the backend is properly deployed and accessible

Write-Host "`n🧪 Railway Backend Deployment Test`n" -ForegroundColor Cyan
Write-Host "Testing: https://social-media-backend-production-8924.up.railway.app`n" -ForegroundColor Yellow

$baseUrl = "https://social-media-backend-production-8924.up.railway.app/api"
$testsPassed = 0
$testsFailed = 0

# Function to display test results
function Test-Endpoint {
    param(
        [string]$TestName,
        [scriptblock]$TestScript
    )
    
    Write-Host "[$TestName]" -ForegroundColor Yellow -NoNewline
    Write-Host " Testing..." -NoNewline
    
    try {
        & $TestScript
        Write-Host " ✅ PASSED" -ForegroundColor Green
        $script:testsPassed++
        return $true
    } catch {
        Write-Host " ❌ FAILED" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray

# Test 1: Basic Connectivity
Test-Endpoint "Test 1: Basic Connectivity" {
    $response = Invoke-WebRequest -Uri "$baseUrl/auth/signup" -Method OPTIONS -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -ne 200) {
        throw "Expected status 200, got $($response.StatusCode)"
    }
}

# Test 2: CORS Headers Present
Test-Endpoint "Test 2: CORS Headers" {
    $response = Invoke-WebRequest -Uri "$baseUrl/auth/signup" -Method OPTIONS -UseBasicParsing -TimeoutSec 10
    $headers = $response.Headers
    
    if (-not $headers.ContainsKey('Access-Control-Allow-Origin')) {
        throw "Missing Access-Control-Allow-Origin header"
    }
    
    if (-not $headers.ContainsKey('Access-Control-Allow-Methods')) {
        throw "Missing Access-Control-Allow-Methods header"
    }
    
    Write-Host "`n  CORS Origin: $($headers['Access-Control-Allow-Origin'])" -ForegroundColor Gray
    Write-Host "  CORS Methods: $($headers['Access-Control-Allow-Methods'])" -ForegroundColor Gray
}

# Test 3: Signup Endpoint
Test-Endpoint "Test 3: Signup Endpoint" {
    $randomEmail = "test$(Get-Random -Maximum 999999)@example.com"
    $body = @{
        name = "Test User"
        email = $randomEmail
        password = "test123"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/signup" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 10
        
        if (-not $response.token) {
            throw "No token received in response"
        }
        
        Write-Host "`n  ✓ User created successfully" -ForegroundColor Gray
        Write-Host "  ✓ JWT token received" -ForegroundColor Gray
        
        # Store token for next tests
        $script:testToken = $response.token
        $script:testEmail = $randomEmail
        
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            # Check if it's a duplicate email error (which means endpoint works)
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errorResponse.message -like "*already exists*") {
                Write-Host "`n  ✓ Endpoint working (duplicate email)" -ForegroundColor Gray
                return
            }
        }
        throw
    }
}

# Test 4: Login Endpoint (if signup worked)
if ($script:testToken) {
    Test-Endpoint "Test 4: Login Endpoint" {
        $body = @{
            email = $script:testEmail
            password = "test123"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 10
        
        if (-not $response.token) {
            throw "No token received in response"
        }
        
        Write-Host "`n  ✓ Login successful" -ForegroundColor Gray
        Write-Host "  ✓ JWT token received" -ForegroundColor Gray
    }
    
    # Test 5: Protected Endpoint
    Test-Endpoint "Test 5: Protected Endpoint (Get User)" {
        $headers = @{
            "Authorization" = "Bearer $($script:testToken)"
        }
        
        $response = Invoke-RestMethod -Uri "$baseUrl/users/me" `
            -Method GET `
            -Headers $headers `
            -TimeoutSec 10
        
        if (-not $response.email) {
            throw "Invalid user response"
        }
        
        Write-Host "`n  ✓ Authentication working" -ForegroundColor Gray
        Write-Host "  ✓ User data retrieved: $($response.email)" -ForegroundColor Gray
    }
    
    # Test 6: Get Posts Endpoint
    Test-Endpoint "Test 6: Get Posts Feed" {
        $headers = @{
            "Authorization" = "Bearer $($script:testToken)"
        }
        
        $response = Invoke-RestMethod -Uri "$baseUrl/posts" `
            -Method GET `
            -Headers $headers `
            -TimeoutSec 10
        
        Write-Host "`n  ✓ Posts endpoint accessible" -ForegroundColor Gray
        Write-Host "  ✓ Retrieved $($response.Count) posts" -ForegroundColor Gray
    }
}

# Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
Write-Host "📊 Test Summary`n" -ForegroundColor Cyan
Write-Host "  Passed: $testsPassed ✅" -ForegroundColor Green
Write-Host "  Failed: $testsFailed ❌" -ForegroundColor Red
Write-Host "  Total:  $($testsPassed + $testsFailed)`n" -ForegroundColor Yellow

if ($testsFailed -eq 0) {
    Write-Host "🎉 All tests passed! Backend is ready!" -ForegroundColor Green
    Write-Host "`n✨ Your frontend can now connect to:`n" -ForegroundColor Cyan
    Write-Host "   $baseUrl`n" -ForegroundColor White
} else {
    Write-Host "⚠️  Some tests failed. Check the errors above." -ForegroundColor Yellow
    Write-Host "`n📋 Troubleshooting steps:`n" -ForegroundColor Cyan
    Write-Host "   1. Check Railway deployment status" -ForegroundColor White
    Write-Host "   2. Review Railway logs for errors" -ForegroundColor White
    Write-Host "   3. Verify MongoDB connection" -ForegroundColor White
    Write-Host "   4. Ensure latest code is deployed`n" -ForegroundColor White
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
