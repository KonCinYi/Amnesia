@echo off
chcp 65001 >nul
title Глобальная очистка ПК
color 0A

:: Запрос прав администратора
fltmc >nul 2>&1 || (
    echo Запрос прав администратора...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Запуск PowerShell скрипта
echo Запуск очистки...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$usersPath = 'C:\Users';
$excludeFolders = @('Public', 'Default', 'Default User', 'All Users', 'Administrator');
$userProfiles = Get-ChildItem -Path $usersPath -Directory -Force | Where-Object { $_.Name -notin $excludeFolders };
$limitDate = (Get-Date).AddDays(-5);
$browserPaths = @(
    'AppData\Local\Google\Chrome\User Data\Default',
    'AppData\Local\Google\Chrome\User Data\Profile*',
    'AppData\Local\Microsoft\Edge\User Data\Default',
    'AppData\Local\Microsoft\Edge\User Data\Profile*',
    'AppData\Local\Yandex\YandexBrowser\User Data\Default',
    'AppData\Local\Yandex\YandexBrowser\User Data\Profile*',
    'AppData\Local\BraveSoftware\Brave-Browser\User Data\Default',
    'AppData\Local\Vivaldi\User Data\Default',
    'AppData\Local\Chromium\User Data\Default',
    'AppData\Local\Mail.Ru\Atom\User Data\Default',
    'AppData\Local\Comodo\Dragon\User Data\Default',
    'AppData\Local\AVAST Software\Browser\User Data\Default',
    'AppData\Local\AVG\Browser\User Data\Default',
    'AppData\Local\CCleaner Browser\User Data\Default',
    'AppData\Local\CentBrowser\User Data\Default',
    'AppData\Local\Slimjet\User Data\Default',
    'AppData\Local\360Chrome\Chrome\User Data\Default',
    'AppData\Local\UCBrowser\User Data_i18n\Default',
    'AppData\Local\Epic Privacy Browser\User Data\Default',
    'AppData\Roaming\Opera Software\Opera Stable',
    'AppData\Roaming\Opera Software\Opera GX Stable',
    'AppData\Roaming\Opera Software\Opera Neon\User Data\Default',
    'AppData\Roaming\Mozilla\Firefox',
    'AppData\Local\Mozilla\Firefox',
    'AppData\Roaming\Waterfox',
    'AppData\Roaming\Moonchild Productions\Pale Moon'
);

Clear-Host;
Write-Host '=======================================================' -ForegroundColor Cyan;
Write-Host '  ГЛОБАЛЬНАЯ ОЧИСТКА РАБОЧИХ СТАНЦИЙ (TEMP + БРАУЗЕРЫ) ' -ForegroundColor Cyan;
Write-Host '=======================================================' -ForegroundColor Cyan;
Write-Host '';

foreach ($user in $userProfiles) {
    Write-Host '[*] Пользователь: $($user.Name)' -ForegroundColor Yellow;
    
    $tempPath = Join-Path -Path $user.FullName -ChildPath 'AppData\Local\Temp';
    if (Test-Path $tempPath) {
        Write-Host '    -> Очистка Temp (только файлы старше 5 дней)...' -ForegroundColor DarkGray;
        Get-ChildItem -Path $tempPath -Recurse -File -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt $limitDate } |
            Remove-Item -Force -ErrorAction SilentlyContinue;
    }
    
    foreach ($bPath in $browserPaths) {
        $fullBrowserPath = Join-Path -Path $user.FullName -ChildPath $bPath;
        if (Test-Path $fullBrowserPath) {
            $browserName = $bPath.Split('\')[2];
            if ($bPath -match 'Mozilla|Opera') { 
                $browserName = $bPath.Split('\')[3] 
            };
            Write-Host '    -> [СБРОС] Найден браузер: $browserName' -ForegroundColor Red;
            Remove-Item -Path $fullBrowserPath -Recurse -Force -ErrorAction SilentlyContinue;
        }
    }
    Write-Host '';
}

Write-Host '=======================================================' -ForegroundColor Green;
Write-Host ' УСПЕХ! Мусор удален, браузеры сброшены.' -ForegroundColor Green;
Write-Host '=======================================================' -ForegroundColor Green;
"

pause
