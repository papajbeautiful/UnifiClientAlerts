# Fix PHP 8.1 nullable parameter deprecation warnings
# Run this from your unificlientalerts directory

$clientFile = "src/Unifi-API-client/Client.php"

if (!(Test-Path $clientFile)) {
    Write-Error "Client.php not found! Make sure you're in the unificlientalerts directory."
    exit 1
}

# Read the file
$content = Get-Content $clientFile -Raw

# List of fixes needed based on your deprecation warnings
$fixes = @(
    # Constructor (already done, but including for completeness)
    @{Line=72; Params=@("site", "version")},
    
    # edit_client_fixedip - Line 1171
    @{Line=1171; Params=@("network_id", "fixed_ip")},
    
    # create_tag - Line 1523
    @{Line=1523; Params=@("devices_macs")},
    
    # stat_voucher - Line 2064
    @{Line=2064; Params=@("create_time")},
    
    # stat_payment - Line 2077
    @{Line=2077; Params=@("within")},
    
    # create_voucher - Line 2127
    @{Line=2127; Params=@("up", "down", "megabytes")},
    
    # list_dpi_stats_filtered - Line 2217
    @{Line=2217; Params=@("cat_filter")},
    
    # create_wlan - Line 2821
    @{Line=2821; Params=@("vlan_enabled", "vlan_id", "ap_group_ids")},
    
    # count_alarms - Line 3006
    @{Line=3006; Params=@("archived")},
    
    # create_radius_account - Line 3265
    @{Line=3265; Params=@("tunnel_type", "tunnel_medium_type", "vlan")},
    
    # list_aps - Line 3446
    @{Line=3446; Params=@("device_mac")}
)

# Apply regex replacements for each parameter
foreach ($fix in $fixes) {
    foreach ($param in $fix.Params) {
        # Pattern to find parameters with type hints and null default
        # This handles various type hints: string, int, bool, array
        $patterns = @(
            "(string\s+\$$param\s*=\s*null)",
            "(int\s+\$$param\s*=\s*null)",
            "(bool\s+\$$param\s*=\s*null)",
            "(array\s+\$$param\s*=\s*null)"
        )
        
        foreach ($pattern in $patterns) {
            if ($content -match $pattern) {
                $oldMatch = $matches[1]
                $newMatch = $oldMatch -replace "^(string|int|bool|array)", "?`$1"
                $content = $content -replace [regex]::Escape($oldMatch), $newMatch
                Write-Host "Fixed: $param (changed '$oldMatch' to '$newMatch')" -ForegroundColor Green
            }
        }
    }
}

# Write the updated content back
$content | Set-Content $clientFile -NoNewline

Write-Host "`nAll nullable parameter deprecations fixed!" -ForegroundColor Cyan
Write-Host "Now commit and rebuild the container." -ForegroundColor Yellow