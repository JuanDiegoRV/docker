@echo off
echo Building Docker image locally...

REM Build the image
docker build -t sirha-backend:latest .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! 
    echo.
    echo To run the container:
    echo docker run -p 8080:8080 sirha-backend:latest
    echo.
    echo To run with environment variables:
    echo docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=prod sirha-backend:latest
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
