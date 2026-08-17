@echo off
setlocal
cd /d "%~dp0"
echo ==========================================
echo Warqnaa V0.4.5+201 Upgrade
ECHO Copy this patch OVER the project root first.
echo ==========================================
for /f "usebackq delims=" %%F in ("V201_DELETE_OLD_FILES.txt") do (
  if exist "%%F" del /f /q "%%F" >nul 2>nul
)
if not exist "backend-laravel\storage\framework\views" mkdir "backend-laravel\storage\framework\views"
if not exist "backend-laravel\storage\framework\cache\data" mkdir "backend-laravel\storage\framework\cache\data"
if not exist "backend-laravel\storage\framework\sessions" mkdir "backend-laravel\storage\framework\sessions"
if not exist "backend-laravel\bootstrap\cache" mkdir "backend-laravel\bootstrap\cache"
python tools\test_v201_gameplay_admin_contract.py || goto :fail
python tools\validate_release.py || goto :fail
if exist "backend-laravel\vendor\autoload.php" (
  pushd backend-laravel
  php artisan optimize:clear || goto :phpfail
  php artisan migrate --force || goto :phpfail
  php artisan db:seed --force || goto :phpfail
  php artisan test || goto :phpfail
  popd
)
echo.
echo V201 UPGRADE: PASS
goto :eof
:phpfail
popd
:fail
echo.
echo V201 UPGRADE: FAILED
exit /b 1
