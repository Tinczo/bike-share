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

Write-Host "--- TEST: BIKE AVAILABILITY CYCLE ---" -ForegroundColor Cyan

# 0. Top-up Wallet to ensure eligibility
Call-Api -Method "POST" -Path "/wallet/topup" -Body @{ amount = 50; method = "TEST_SCRIPT" } | Out-Null

# 1. Cleanup: Check for active rentals
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

# 2. Find an Available Bike
Step "2. Find an Available Bike"
$mapRes = Call-Api -Method "GET" -Path "/map/bikes?lat=51.1&lng=17.0&radius=10"
$targetBike = $mapRes.bikes | Where-Object { $_.status -eq "AVAILABLE" } | Select-Object -First 1

if (-not $targetBike) {
    Write-Error "No available bikes found to test with!"
    exit
}
$bikeId = $targetBike.id_roweru
Write-Host "Selected Bike ID: $bikeId (Status: $($targetBike.status))" -ForegroundColor Green

# 3. Start Rental
Step "3. Start Rental for Bike $bikeId"
$startRes = Call-Api -Method "POST" -Path "/rental/start" -Body @{ bikeId = $bikeId; method = "QR" }

if ($startRes.rental) {
    $rentalId = $startRes.rental.id_wypozyczenia
    Write-Host "Rental Started! ID: $rentalId" -ForegroundColor Green
} else {
    Write-Error "Failed to start rental."
    exit
}

# 4. Verify Bike is NOT Available
Step "4. Verify Bike Status is RENTED (Unavailable)"
$mapCheck1 = Call-Api -Method "GET" -Path "/map/bikes?lat=51.1&lng=17.0&radius=10"
$bikeAfterRent = $mapCheck1.bikes | Where-Object { $_.id_roweru -eq $bikeId }

if ($bikeAfterRent.status -eq "RENTED") {
    Write-Host "Success: Bike status is now '$($bikeAfterRent.status)'" -ForegroundColor Green
} else {
    Write-Error "Failure: Bike status is '$($bikeAfterRent.status)' (Expected: RENTED)"
    exit
}

# 5. End Rental
Step "5. End Rental $rentalId"
Start-Sleep -Seconds 1
$endRes = Call-Api -Method "POST" -Path "/rental/$rentalId/end"

if ($endRes.rental.status -eq "FINISHED") {
    Write-Host "Rental Finished." -ForegroundColor Green
} else {
    Write-Error "Failed to end rental."
    exit
}

# 6. Verify Bike IS Available Again
Step "6. Verify Bike Status is AVAILABLE again"
$mapCheck2 = Call-Api -Method "GET" -Path "/map/bikes?lat=51.1&lng=17.0&radius=10"
$bikeAfterEnd = $mapCheck2.bikes | Where-Object { $_.id_roweru -eq $bikeId }

if ($bikeAfterEnd.status -eq "AVAILABLE") {
    Write-Host "Success: Bike status returned to '$($bikeAfterEnd.status)'" -ForegroundColor Green
} else {
    Write-Error "Failure: Bike status is '$($bikeAfterEnd.status)' (Expected: AVAILABLE)"
    exit
}

Write-Host "`nTest Passed Successfully!" -ForegroundColor Green
