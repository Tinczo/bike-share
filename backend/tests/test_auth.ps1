$baseUrl = "http://localhost:3000/api"

function Test-Endpoint {
    param (
        [string]$Method,
        [string]$Url,
        [hashtable]$Body,
        [string]$Description
    )

    Write-Host "Testing: $Description" -ForegroundColor Cyan
    try {
        $params = @{
            Method = $Method
            Uri = $Url
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json
        }

        $response = Invoke-RestMethod @params
        Write-Host "Success!" -ForegroundColor Green
        Write-Host "Response:"
        $response | ConvertTo-Json -Depth 5 | Write-Host
        return $response
    }
    catch {
        Write-Host "Failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Server Response: $responseBody"
        }
        return $null
    }
    Write-Host "-" * 50
}

# 1. Test Register
$randomId = Get-Random -Minimum 1000 -Maximum 9999
$newUserEmail = "user$randomId@test.com"
$password = "pass$randomId"

Write-Host "`n--- AUTHENTICATION FLOW ---`n" -ForegroundColor Yellow

Test-Endpoint -Method "POST" `
    -Url "$baseUrl/auth/register" `
    -Body @{ email = $newUserEmail; password = $password } `
    -Description "Register New User ($newUserEmail)"

# 2. Test Login with New User
Test-Endpoint -Method "POST" `
    -Url "$baseUrl/auth/login" `
    -Body @{ email = $newUserEmail; password = $password } `
    -Description "Login with New User"

# 3. Test Login with Default Test User
Test-Endpoint -Method "POST" `
    -Url "$baseUrl/auth/login" `
    -Body @{ email = "test@example.com"; password = "password123" } `
    -Description "Login with Default User"

# 4. Test Invalid Login
Write-Host "Testing: Invalid Login" -ForegroundColor Cyan
try {
    Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/login" `
        -ContentType "application/json" `
        -Body (@{ email = "wrong@test.com"; password = "wrong" } | ConvertTo-Json) `
        -ErrorAction Stop
}
catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Host "Success! Got expected 401 Unauthorized." -ForegroundColor Green
    } else {
        Write-Host "Failed! Expected 401, got $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}
