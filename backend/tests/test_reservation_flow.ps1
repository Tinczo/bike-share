$baseUrl = "http://localhost:3000/api"

# Helper to print steps
function Step { param([string]$msg) Write-Host "`n[$msg]" -ForegroundColor Yellow }

# Helper wrapper for Invoke-RestMethod
function Call-Api {
    param (
        [string]$Method,
        [string]$Path,
        [hashtable]$Body = $null
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
        # Check if 404 (often used for 'no active reservation' which is fine during cleanup)
        if ($_.Exception.Response.StatusCode.value__ -ne 404) {
             Write-Host "Error calling $Path : $($_.Exception.Message)" -ForegroundColor Red
        }
        return $null
    }
}

Write-Host "--- RESERVATION FLOW TEST ---" -ForegroundColor Cyan

# 1. Cleanup Active Reservations
Step "1. Cleanup: Check/Cancel active reservations"
$activeRes = Call-Api -Method "GET" -Path "/rental/reservation/active"
if ($activeRes -and $activeRes.reservation) {
    $resId = $activeRes.reservation.id_rezerwacji
    Write-Host "Found active reservation: $resId. Cancelling..."
    Call-Api -Method "DELETE" -Path "/rental/reservation/$resId" | Out-Null
    Write-Host "Cleanup complete."
} else {
    Write-Host "No active reservations found."
}

# 2. Get Available Bike
Step "2. Get Available Bike"
$mapRes = Call-Api -Method "GET" -Path "/map/bikes?lat=51.1&lng=17.0&radius=10"
$availableBike = $mapRes.bikes | Where-Object { $_.status -eq "AVAILABLE" } | Select-Object -First 1

if (-not $availableBike) {
    Write-Error "No available bikes found to reserve!"
    exit
}
Write-Host "Selected Bike: $($availableBike.id_roweru)" -ForegroundColor Green

# 3. Create Reservation
Step "3. Create Reservation"
$createRes = Call-Api -Method "POST" -Path "/rental/reservation" -Body @{ bikeId = $availableBike.id_roweru }

if ($createRes -and $createRes.reservation) {
    $reservationId = $createRes.reservation.id_rezerwacji
    Write-Host "Reservation Created! ID: $reservationId" -ForegroundColor Green
    Write-Host "Expires at: $($createRes.reservation.data_wygasniecia)"
} else {
    Write-Error "Failed to create reservation."
    exit
}

# 4. Verify Active Reservation
Step "4. Verify Active Reservation"
$activeCheck = Call-Api -Method "GET" -Path "/rental/reservation/active"
if ($activeCheck.reservation.id_rezerwacji -eq $reservationId) {
    Write-Host "Verified: Reservation is active." -ForegroundColor Green
} else {
    Write-Error "Failed to verify active reservation."
}

# 5. Cancel Reservation
Step "5. Cancel Reservation"
$cancelRes = Call-Api -Method "DELETE" -Path "/rental/reservation/$reservationId"
if ($cancelRes.success) {
    Write-Host "Reservation Cancelled Successfully." -ForegroundColor Green
} else {
    Write-Error "Failed to cancel reservation."
}
