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

Write-Host "--- HISTORY & FAULTS API TEST ---" -ForegroundColor Cyan

# 1. Get Rental History
Step "1. Get Rental History"
$rentalHistory = Call-Api -Method "GET" -Path "/history/rentals"
if ($rentalHistory) {
    Write-Host "Rental history items: $($rentalHistory.rentals.Count)" -ForegroundColor Green
    if ($rentalHistory.rentals.Count -gt 0) {
        $rentalHistory.rentals | ForEach-Object {
            Write-Host "  - Rental: $($_.id_wypozyczenia), Bike: $($_.id_roweru), Cost: $($_.koszt_calkowity) PLN"
        }
    }
} else {
    Write-Host "No rental history returned." -ForegroundColor Yellow
}

# 2. Get Fault Report History
Step "2. Get Fault Report History"
$faultHistory = Call-Api -Method "GET" -Path "/history/faults"
if ($faultHistory) {
    Write-Host "Fault report items: $($faultHistory.faults.Count)" -ForegroundColor Green
    $faultHistory.faults | ForEach-Object {
        $status = if ($_.czy_potwierdzone) { "Confirmed" } elseif ($_.czy_zweryfikowane) { "Verified" } else { "Pending" }
        Write-Host "  - Fault: $($_.id_zgloszenia), Bike: $($_.id_roweru), Type: $($_.typ_usterki), Status: $status"
    }
    $initialFaultCount = $faultHistory.faults.Count
} else {
    Write-Host "No fault history returned." -ForegroundColor Yellow
    $initialFaultCount = 0
}

# 3. Report a New Fault (without description)
Step "3. Report New Fault (flat tire, no description)"
$newFault1 = Call-Api -Method "POST" -Path "/faults/report" -Body @{
    bikeId = "1"
    type = "przebita_opona"
}
if ($newFault1 -and $newFault1.fault) {
    Write-Host "Fault created: $($newFault1.fault.id_zgloszenia)" -ForegroundColor Green
    Write-Host "  Type: $($newFault1.fault.typ_usterki)"
    Write-Host "  Verified: $($newFault1.fault.czy_zweryfikowane)"
}

# 4. Report a New Fault (with description)
Step "4. Report New Fault (other, with description)"
$newFault2 = Call-Api -Method "POST" -Path "/faults/report" -Body @{
    bikeId = "2"
    type = "inne"
    description = "Siodełko jest poluzowane i trzeszczy podczas jazdy"
}
if ($newFault2 -and $newFault2.fault) {
    Write-Host "Fault created: $($newFault2.fault.id_zgloszenia)" -ForegroundColor Green
    Write-Host "  Type: $($newFault2.fault.typ_usterki)"
    Write-Host "  Description: $($newFault2.fault.opis)"
}

# 5. Verify fault appears in history
Step "5. Verify New Faults Appear in History"
$updatedHistory = Call-Api -Method "GET" -Path "/history/faults"
if ($updatedHistory) {
    $newCount = $updatedHistory.faults.Count
    $expectedCount = $initialFaultCount + 2
    if ($newCount -ge $expectedCount) {
        Write-Host "Fault count increased: $initialFaultCount -> $newCount" -ForegroundColor Green
    } else {
        Write-Host "Warning: Expected at least $expectedCount faults, got $newCount" -ForegroundColor Yellow
    }
}

# 6. Test invalid fault type
Step "6. Test Invalid Fault Type (should fail)"
try {
    $params = @{
        Method = "POST"
        Uri = "$baseUrl/faults/report"
        ContentType = "application/json"
        Body = (@{ bikeId = "1"; type = "invalid_type" } | ConvertTo-Json)
        ErrorAction = "Stop"
    }
    Invoke-RestMethod @params
    Write-Host "Unexpected success!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Host "Got expected 400 Bad Request." -ForegroundColor Green
    } else {
        Write-Host "Got unexpected status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# 7. Test missing bike ID
Step "7. Test Missing Bike ID (should fail)"
try {
    $params = @{
        Method = "POST"
        Uri = "$baseUrl/faults/report"
        ContentType = "application/json"
        Body = (@{ type = "przebita_opona" } | ConvertTo-Json)
        ErrorAction = "Stop"
    }
    Invoke-RestMethod @params
    Write-Host "Unexpected success!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Host "Got expected 400 Bad Request." -ForegroundColor Green
    } else {
        Write-Host "Got unexpected status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`n--- TEST COMPLETE ---" -ForegroundColor Cyan
