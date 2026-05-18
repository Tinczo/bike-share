$baseUrl = "http://localhost:3000/api"

function Step { param([string]$msg) Write-Host "`n[$msg]" -ForegroundColor Yellow }

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

Write-Host "--- WALLET OPERATIONS TEST ---" -ForegroundColor Cyan

# 1. Get Initial Wallet State
Step "1. Get Initial Wallet State"
$wallet = Call-Api -Method "GET" -Path "/wallet"
$initialBalance = $wallet.wallet.saldo
Write-Host "Initial Balance: $initialBalance PLN" -ForegroundColor Green

# 2. Add Payment Method
Step "2. Add Payment Method (Mastercard)"
$cardBody = @{
    type = "CARD"
    lastFourDigits = "9999"
    cardBrand = "Mastercard"
}
$addCardRes = Call-Api -Method "POST" -Path "/wallet/payment-methods" -Body $cardBody

if ($addCardRes.success) {
    Write-Host "Card added successfully. ID: $($addCardRes.method.id_metody)" -ForegroundColor Green
} else {
    Write-Error "Failed to add card."
    exit
}

# 3. Top Up Wallet
Step "3. Top Up Wallet (+25.00 PLN)"
$topUpAmount = 25.00
$topUpRes = Call-Api -Method "POST" -Path "/wallet/topup" -Body @{ amount = $topUpAmount; method = "BLIK" }

if ($topUpRes.success) {
    Write-Host "Top-up successful. New Balance: $($topUpRes.newBalance) PLN" -ForegroundColor Green
    if ($topUpRes.newBalance -eq ($initialBalance + $topUpAmount)) {
        Write-Host "Balance verification passed." -ForegroundColor Green
    } else {
        Write-Error "Balance verification failed! Expected $($initialBalance + $topUpAmount), got $($topUpRes.newBalance)"
    }
} else {
    Write-Error "Top-up failed."
    exit
}

# 4. Verify Transaction History
Step "4. Verify Transaction History"
$historyRes = Call-Api -Method "GET" -Path "/wallet/transactions"
$lastTx = $historyRes.transactions | Select-Object -First 1

Write-Host "Last Transaction:"
Write-Host "  Type: $($lastTx.typ)"
Write-Host "  Amount: $($lastTx.kwota)"
Write-Host "  Desc: $($lastTx.opis)"

if ($lastTx.typ -eq "TOP_UP" -and $lastTx.kwota -eq $topUpAmount) {
    Write-Host "Transaction history verification passed." -ForegroundColor Green
} else {
    Write-Error "Transaction history verification failed."
}
