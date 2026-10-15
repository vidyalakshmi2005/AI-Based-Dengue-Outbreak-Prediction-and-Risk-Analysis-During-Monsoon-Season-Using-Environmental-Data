@echo off
title DengueWatch - Project Launcher
color 0A

echo ============================================
echo       DengueWatch Project Launcher
echo ============================================
echo.

:: -----------------------------------------------
:: Check for Node.js
:: -----------------------------------------------
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    echo         Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

:: -----------------------------------------------
:: Check for MongoDB
:: -----------------------------------------------
where mongod >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] mongod not found in PATH.
    echo           MongoDB may not be installed, or its bin folder is not in PATH.
    echo           Download MongoDB from https://www.mongodb.com/try/download/community
    echo.
    echo           Attempting to start anyway - press Ctrl+C in the MongoDB window
    echo           if it fails and fix the installation first.
    echo.
    pause
)

set ROOT=%~dp0DengueWatch

:: -----------------------------------------------
:: Install dependencies if node_modules is missing
:: -----------------------------------------------
echo [1/3] Checking backend dependencies...
if not exist "%ROOT%\DengueWatch\backend\node_modules" (
    echo       Installing backend dependencies...
    start /wait cmd /c "cd /d "%ROOT%\DengueWatch\backend" && npm install"
) else (
    echo       Backend dependencies OK.
)

echo [2/3] Checking frontend dependencies...
if not exist "%ROOT%\DengueWatch\frontend\node_modules" (
    echo       Installing frontend dependencies...
    start /wait cmd /c "cd /d "%ROOT%\DengueWatch\frontend" && npm install"
) else (
    echo       Frontend dependencies OK.
)

echo [3/3] Checking root (Vite) dependencies...
if not exist "%ROOT%\node_modules" (
    echo       Installing root dependencies...
    start /wait cmd /c "cd /d "%ROOT%" && npm install"
) else (
    echo       Root dependencies OK.
)

echo.
echo ============================================
echo  Starting all services...
echo ============================================
echo.

:: -----------------------------------------------
:: 1. Start MongoDB
:: -----------------------------------------------
echo [DATABASE] Starting MongoDB...
set MONGO_DATA=%ROOT%\DengueWatch\database\data
if not exist "%MONGO_DATA%" mkdir "%MONGO_DATA%"

start "DengueWatch - MongoDB" cmd /k "title DengueWatch - MongoDB && color 0B && echo Starting MongoDB... && mongod --dbpath "%MONGO_DATA%" --port 27017"

:: Give MongoDB a moment to initialise
timeout /t 3 /nobreak >nul

:: -----------------------------------------------
:: 2. Start Backend (Express)
:: -----------------------------------------------
echo [BACKEND]  Starting Express backend...
start "DengueWatch - Backend" cmd /k "title DengueWatch - Backend && color 0E && cd /d "%ROOT%\DengueWatch\backend" && echo Starting backend... && npm start"

:: Give backend a moment to start
timeout /t 2 /nobreak >nul

:: -----------------------------------------------
:: 3. Start Frontend (React)
:: -----------------------------------------------
echo [FRONTEND] Starting React frontend...
start "DengueWatch - Frontend" cmd /k "title DengueWatch - Frontend && color 0D && cd /d "%ROOT%\DengueWatch\frontend" && echo Starting frontend... && npm start"

:: -----------------------------------------------
:: 4. Optionally start the Vite dev server (root)
:: -----------------------------------------------
echo [VITE]     Starting Vite dev server (root)...
start "DengueWatch - Vite" cmd /k "title DengueWatch - Vite && color 09 && cd /d "%ROOT%" && echo Starting Vite... && npm run dev"

echo.
echo ============================================
echo  All services launched in separate windows:
echo    MongoDB   - port 27017
echo    Backend   - http://localhost:5000  (default)
echo    Frontend  - http://localhost:3000  (default)
echo    Vite      - http://localhost:5173  (default)
echo.
echo  Close this window or press any key to exit.
echo ============================================
pause >nul
