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
        Write-Host "Error calling $Path : $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
             $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
             Write-Host $reader.ReadToEnd() -ForegroundColor Red
        }
        return $null
    }
}

Write-Host "--- RENTAL FLOW TEST ---" -ForegroundColor Cyan

# 0. Ensure Wallet Balance
Step "0. Top-up Wallet to ensure eligibility"
Call-Api -Method "POST" -Path "/wallet/topup" -Body @{ amount = 50; method = "TEST_SCRIPT" } | Out-Null

# 1. Check for existing active rentals and end them to clean state
Step "1. Cleanup: Check for active rentals"
$activeRentalRes = Call-Api -Method "GET" -Path "/rental/active"
if ($activeRentalRes -and $activeRentalRes.rental) {
    $rId = $activeRentalRes.rental.id_wypozyczenia
    Write-Host "Found active rental: $rId. Ending it..."
    Call-Api -Method "POST" -Path "/rental/$rId/end" | Out-Null
    Write-Host "Cleanup complete."
} else {
    Write-Host "No active rentals found."
}

# 2. Get Available Bikes
Step "2. Get Available Bikes"
$mapRes = Call-Api -Method "GET" -Path "/map/bikes?lat=51.1&lng=17.0&radius=10"
$availableBike = $mapRes.bikes | Where-Object { $_.status -eq "AVAILABLE" } | Select-Object -First 1

if (-not $availableBike) {
    Write-Error "No available bikes found to rent!"
    exit
}
Write-Host "Selected Bike: $($availableBike.id_roweru) ($($availableBike.kod_qr))" -ForegroundColor Green

# 3. Check Eligibility
Step "3. Check Eligibility"
$eligibility = Call-Api -Method "GET" -Path "/rental/eligibility"
if (-not $eligibility.uprawniony) {
    Write-Error "User not eligible: $($eligibility.powod)"
    exit
}
Write-Host "User is eligible." -ForegroundColor Green

# 4. Start Rental
Step "4. Start Rental"
$startRes = Call-Api -Method "POST" -Path "/rental/start" -Body @{ bikeId = $availableBike.id_roweru; method = "QR" }

if ($startRes.rental) {
    Write-Host "Rental Started! ID: $($startRes.rental.id_wypozyczenia)" -ForegroundColor Green
    $rentalId = $startRes.rental.id_wypozyczenia
} else {
    Write-Error "Failed to start rental."
    exit
}

# 5. Pause Rental
Step "5. Pause Rental"
$pauseRes = Call-Api -Method "POST" -Path "/rental/$rentalId/pause"
Write-Host "Rental Status: $($pauseRes.rental.status)" -ForegroundColor Green

# 6. Resume Rental
Step "6. Resume Rental"
$resumeRes = Call-Api -Method "POST" -Path "/rental/$rentalId/resume"
Write-Host "Rental Status: $($resumeRes.rental.status)" -ForegroundColor Green

# 7. End Rental
Step "7. End Rental"
Start-Sleep -Seconds 2 # Wait a bit to simulate time
$endRes = Call-Api -Method "POST" -Path "/rental/$rentalId/end"
if ($endRes.rental.status -eq "FINISHED") {
    Write-Host "Rental Finished. Cost: $($endRes.rental.koszt_calkowity) PLN" -ForegroundColor Green
} else {
    Write-Error "Failed to end rental."
}
