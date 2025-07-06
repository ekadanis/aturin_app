@echo off
echo ===== Widget Refresh Script =====
echo Cleaning project...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building and running app...
call flutter run

echo.
echo Done! Now test your widget!
echo 1. Add the widget to your home screen
echo 2. Click on it to verify it opens the Activities tab
echo ================================
