# Script Full Clean Windows - avec Menu Interactif
# Créé par DemonDeV-tech - Exécutez en tant qu’administrateur
# Si nécessaire, exécutez : Set-ExecutionPolicy RemoteSigned -Scope Process

# Forcer UTF-8 pour l'affichage correct
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Nettoyer-Temp {
    Write-Host "🧹 Suppression des fichiers TEMP utilisateur et système..." -ForegroundColor Cyan
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✔️ TEMP nettoyé"
}

function Vider-Corbeille {
    Write-Host "🗑️ Vidage de la corbeille..." -ForegroundColor Cyan
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Host "✔️ Corbeille vidée"
    } catch {
        Write-Host "⚠️ Impossible de vider la corbeille (droits insuffisants ou autre)." -ForegroundColor Yellow
    }
}

function Activer-Vidage-Pagefile {
    Write-Host "💾 Activation du vidage du fichier d’échange au redémarrage..." -ForegroundColor Cyan
    try {
        Set-ItemProperty -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name ClearPageFileAtShutdown -Value 1
        Write-Host "✔️ Vidage activé"
    } catch {
        Write-Host "❌ Erreur lors de la modification de la clé de registre. Droits administrateur requis." -ForegroundColor Red
    }
}

function Liberer-RAM {
    Write-Host "🧠 Libération partielle de la RAM via .NET..." -ForegroundColor Cyan
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
    Write-Host "✔️ RAM libérée (dans la limite de PowerShell)"
}

function Vider-DNS {
    Write-Host "🌐 Vidage du cache DNS..." -ForegroundColor Cyan
    Clear-DnsClientCache
    Write-Host "✔️ Cache DNS vidé"
}

function Nettoyer-WindowsUpdate {
    Write-Host "🪣 Nettoyage du cache Windows Update..." -ForegroundColor Cyan
    try {
        Write-Host "⏳ Arrêt du service Windows Update en cours..." -ForegroundColor Yellow

        $null = Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        $timeout = 15
        $elapsed = 0
        while ((Get-Service -Name wuauserv).Status -ne 'Stopped' -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
        }

        if ((Get-Service -Name wuauserv).Status -eq 'Stopped') {
            Write-Host "✔️ Service Windows Update arrêté"
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✔️ Cache Windows Update nettoyé"
        } else {
            Write-Host "❌ Impossible d'arrêter le service wuauserv dans le délai imparti." -ForegroundColor Red
        }

        Write-Host "🔄 Redémarrage du service Windows Update..." -ForegroundColor Yellow

        $null = Start-Service -Name wuauserv -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        $elapsed = 0
        while ((Get-Service -Name wuauserv).Status -ne 'Running' -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
        }

        if ((Get-Service -Name wuauserv).Status -eq 'Running') {
            Write-Host "✔️ Service Windows Update redémarré"
        } else {
            Write-Host "❌ Impossible de démarrer le service wuauserv dans le délai imparti." -ForegroundColor Red
        }

    } catch {
        Write-Host "⚠️ Erreur lors du nettoyage Windows Update." -ForegroundColor Yellow
    }
}

function Supprimer-Logs {
    Write-Host "📜 Suppression des journaux d’événements..." -ForegroundColor Cyan
    try {
        $logsPath = "$env:SystemRoot\System32\winevt\Logs"
        Get-ChildItem -Path $logsPath -Filter *.evtx | ForEach-Object {
            try {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            } catch {}
        }
        Write-Host "✔️ Journaux supprimés (fichiers logs .evtx)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Erreur lors de la suppression des logs." -ForegroundColor Yellow
    }
}

function Supprimer-Dumps {
    Write-Host "💣 Suppression des fichiers de dump..." -ForegroundColor Cyan
    Remove-Item "C:\Windows\Minidump\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✔️ Fichiers de dump supprimés"
}

function Supprimer-Prefetch {
    Write-Host "⚡ Suppression du cache Prefetch..." -ForegroundColor Cyan
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✔️ Prefetch vidé"
}

function NettoyerCacheNavigateurs {
    param(
        [string]$nomNavigateur,
        [string]$cheminBaseProfiles
    )

    if (-not (Test-Path $cheminBaseProfiles)) {
        Write-Host "⚠️ $nomNavigateur non trouvé" -ForegroundColor Yellow
        return
    }

    # Récupération des profils utilisateurs
    $profiles = Get-ChildItem -Path $cheminBaseProfiles -Directory -ErrorAction SilentlyContinue

    if ($profiles.Count -eq 0) {
        Write-Host "⚠️ Aucun profil trouvé pour $nomNavigateur" -ForegroundColor Yellow
        return
    }

    $profilesAvecCache = @()
    foreach ($profile in $profiles) {
        $cachePath = Join-Path $profile.FullName "Cache"
        if (Test-Path $cachePath) {
            $profilesAvecCache += $profile
        }
    }

    if ($profilesAvecCache.Count -eq 0) {
        Write-Host "⚠️ Aucun cache trouvé pour $nomNavigateur" -ForegroundColor Yellow
    } else {
        Write-Host "🧹 Nettoyage du cache $nomNavigateur pour les profils :" -ForegroundColor Cyan
        foreach ($profile in $profilesAvecCache) {
            $cachePath = Join-Path $profile.FullName "Cache"
            try {
                Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction Stop
                Write-Host "  ✔️ $($profile.Name)" -ForegroundColor Green
            }
            catch {
                Write-Host "  ❌ Erreur lors du nettoyage du cache $nomNavigateur ($($profile.Name)) : $_" -ForegroundColor Red
            }
        }
    }
}

# Chemins des profils
$chromePath   = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$edgePath     = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$firefoxPath  = "$env:APPDATA\Mozilla\Firefox\Profiles"
$operaPath    = "$env:APPDATA\Opera Software\Opera Stable"
$operaGXPath  = "$env:APPDATA\Opera Software\Opera GX Stable"
$bravePath    = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"

function Nettoyer-TousCachesNavigateurs {
    NettoyerCacheNavigateurs -nomNavigateur "Chrome" -cheminBaseProfiles $chromePath
    NettoyerCacheNavigateurs -nomNavigateur "Edge" -cheminBaseProfiles $edgePath
    NettoyerCacheNavigateurs -nomNavigateur "Firefox" -cheminBaseProfiles $firefoxPath
    NettoyerCacheNavigateurs -nomNavigateur "Opera" -cheminBaseProfiles $operaPath
    NettoyerCacheNavigateurs -nomNavigateur "Opera GX" -cheminBaseProfiles $operaGXPath
    NettoyerCacheNavigateurs -nomNavigateur "Brave" -cheminBaseProfiles $bravePath
}

function Top-Processus {
    Write-Host "📊 Top 10 des processus gourmands en RAM :" -ForegroundColor Green
    Get-Process | Sort-Object WorkingSet -Descending | 
        Select-Object -First 10 Name, Id, @{Name="Mémoire (MB)";Expression={"{0:N2}" -f ($_.WorkingSet / 1MB)}} | 
        Format-Table -AutoSize
}

function Get-DisqueLibre {
    $drive = Get-PSDrive -Name C
    return [math]::Round($drive.Free / 1GB, 2)
}

function Show-ProgressMessage {
    param(
        [int]$Step,
        [int]$TotalSteps
    )
    Write-Host "Étape $Step sur $TotalSteps terminée." -ForegroundColor Green
}

function Full-Clean {
    $totalSteps = 11
    $currentStep = 0

    $freeBefore = Get-DisqueLibre
    Write-Host "🖥️ Espace disque libre avant nettoyage : $freeBefore Go" -ForegroundColor Cyan

    Nettoyer-Temp
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Vider-Corbeille
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Activer-Vidage-Pagefile
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Liberer-RAM
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Vider-DNS
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Nettoyer-WindowsUpdate
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Supprimer-Logs
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Supprimer-Dumps
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Supprimer-Prefetch
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Nettoyer-TousCachesNavigateurs
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    Top-Processus
    $currentStep++
    Show-ProgressMessage -Step $currentStep -TotalSteps $totalSteps

    $freeAfter = Get-DisqueLibre
    Write-Host "`n🖥️ Espace disque libre après nettoyage : $freeAfter Go" -ForegroundColor Cyan
    Write-Host "`n✅ Nettoyage complet terminé !" -ForegroundColor Green
}

function Show-Header {
    Clear-Host
    Write-Host ("=" * 48) -ForegroundColor Yellow
    Write-Host "     Script Full Clean Windows - by DemonDeV-tech" -ForegroundColor Cyan
    Write-Host "           Exécutez en tant qu’administrateur" -ForegroundColor Cyan
    Write-Host ("=" * 48) -ForegroundColor Yellow
    Write-Host ""
}

function Show-Footer {
    Write-Host ""
    Write-Host ("=" * 48) -ForegroundColor DarkGray
    Write-Host "   Script créé par DemonDeV-tech - Merci d'utiliser ce script !" -ForegroundColor DarkGray
}

function Show-Menu {
    Write-Host "=== MENU DE NETTOYAGE WINDOWS ===`n" -ForegroundColor Yellow

    $menuItems = @(
        "[1]  🧹 Nettoyer les fichiers temporaires",
        "[2]  🗑️ Vider la corbeille",
        "[3]  💾 Activer le vidage de la mémoire virtuelle",
        "[4]  🧠 Libérer la mémoire RAM",
        "[5]  🌐 Vider le cache DNS",
        "[6]  🪣 Nettoyer Windows Update",
        "[7]  📜 Supprimer les logs d’événements",
        "[8]  💣 Supprimer les fichiers de dump",
        "[9]  ⚡ Supprimer le cache Prefetch",
        "[10] 📊 Afficher les processus gourmands",
        "[11] 🌐 Nettoyer le cache des navigateurs",
        "[12] 🔥 Lancer le nettoyage complet",
        "[0]  🚪 Quitter"
    )

    foreach ($item in $menuItems) { Write-Host $item }
    Show-Footer
    Write-Host ""
}

function Attendre-Confirmation {
    do {
        $input = Read-Host "Tapez 'confirmer' pour revenir au menu"
    } while ($input -ne "confirmer")
}

do {
    Show-Header
    Show-Menu
    $choix = Read-Host "Votre choix"

    switch ($choix) {
        "1" { Nettoyer-Temp; Attendre-Confirmation }
        "2" { Vider-Corbeille; Attendre-Confirmation }
        "3" { Activer-Vidage-Pagefile; Attendre-Confirmation }
        "4" { Liberer-RAM; Attendre-Confirmation }
        "5" { Vider-DNS; Attendre-Confirmation }
        "6" { Nettoyer-WindowsUpdate; Attendre-Confirmation }
        "7" { Supprimer-Logs; Attendre-Confirmation }
        "8" { Supprimer-Dumps; Attendre-Confirmation }
        "9" { Supprimer-Prefetch; Attendre-Confirmation }
        "10" { Top-Processus; Attendre-Confirmation }
        "11" { Nettoyer-TousCachesNavigateurs; Attendre-Confirmation }
        "12" { Full-Clean; Attendre-Confirmation }
        "0" { Write-Host "Au revoir !" -ForegroundColor Cyan; exit }
        default { Write-Host "Choix invalide. Essayez encore." -ForegroundColor Red; Attendre-Confirmation }
    }
} while ($true)
