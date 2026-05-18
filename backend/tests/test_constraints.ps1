$baseUrl = "http://localhost:3000/api"

function Step { param([string]$msg) Write-Host "`n[$msg]" -ForegroundColor Yellow }

function Call-Api {
    param (
        [string]$Method,
        [string]$Path,
        [hashtable]$Body = $null,
        [switch]$IgnoreErrors
    )
    $params = @{
        Method = $Method
        Uri = "$baseUrl$Path"
        ContentType = "application/json"
    }
    if ($Body) { $params.Body = $Body | ConvertTo-Json }
    
    try {
        return Invoke-RestMethod @params
    } catch {
        if (-not $IgnoreErrors) {
            Write-Host "API Error ($($_.Exception.Response.StatusCode)): $($_.Exception.Message)" -ForegroundColor Red
        }
        return $_.Exception.Response
    }
}

Write-Host "--- SYSTEM CONSTRAINTS TEST (Single Reservation Rule) ---" -ForegroundColor Cyan

# 1. Cleanup
Step "1. Cleanup existing reservations"
$activeRes = Call-Api -Method "GET" -Path "/rental/reservation/active" -IgnoreErrors
if ($activeRes -and $activeRes.StatusCode -eq 200) { # If 200, we have a body (Invoke-RestMethod returns body for 200)
    # Re-call without IgnoreErrors to get the object easily or parse
    $realRes = Invoke-RestMethod -Method Get -Uri "$baseUrl/rental/reservation/active"
    $resId = $realRes.reservation.id_rezerwacji
    Write-Host "Cancelling existing reservation: $resId"
    Call-Api -Method "DELETE" -Path "/rental/reservation/$resId" | Out-Null
}

# 2. Get Two Available Bikes
Step "2. Find two available bikes"
$mapRes = Invoke-RestMethod -Method Get -Uri "$baseUrl/map/bikes"
$bikes = $mapRes.bikes | Where-Object { $_.status -eq "AVAILABLE" } | Select-Object -First 2

if ($bikes.Count -lt 2) {
    Write-Error "Not enough available bikes to run test."
    exit
}

$bike1 = $bikes[0].id_roweru
$bike2 = $bikes[1].id_roweru
Write-Host "Bike 1: $bike1"
Write-Host "Bike 2: $bike2"

# 3. Reserve Bike 1
Step "3. Reserve Bike 1 (Should Succeed)"
$res1 = Call-Api -Method "POST" -Path "/rental/reservation" -Body @{ bikeId = $bike1 }
if ($res1.reservation) {
    Write-Host "Success: Reserved Bike 1 ($($res1.reservation.id_rezerwacji))" -ForegroundColor Green
    $resId1 = $res1.reservation.id_rezerwacji
} else {
    Write-Error "Failed to reserve Bike 1"
    exit
}

# 4. Attempt to Reserve Bike 2
Step "4. Attempt to Reserve Bike 2 (Should Fail)"
try {
    Invoke-RestMethod -Method Post -Uri "$baseUrl/rental/reservation" -Body (@{ bikeId = $bike2 } | ConvertTo-Json) -ContentType "application/json" -ErrorAction Stop
    Write-Error "FAILURE: System allowed second reservation!"
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 409) {
        Write-Host "Success: System rejected second reservation (409 Conflict)" -ForegroundColor Green
    } else {
        Write-Error "Unexpected error code: $code"
    }
}

# 5. Cancel First Reservation
Step "5. Cancel First Reservation"
Call-Api -Method "DELETE" -Path "/rental/reservation/$resId1" | Out-Null
Write-Host "Cancelled Reservation 1" -ForegroundColor Green

# 6. Reserve Bike 2 Again
Step "6. Reserve Bike 2 Again (Should Succeed now)"
$res2 = Call-Api -Method "POST" -Path "/rental/reservation" -Body @{ bikeId = $bike2 }
if ($res2.reservation) {
    Write-Host "Success: Reserved Bike 2 ($($res2.reservation.id_rezerwacji))" -ForegroundColor Green
    # Clean up at the end
    Call-Api -Method "DELETE" -Path "/rental/reservation/$($res2.reservation.id_rezerwacji)" | Out-Null
} else {
    Write-Error "Failed to reserve Bike 2 after cancellation"
}
