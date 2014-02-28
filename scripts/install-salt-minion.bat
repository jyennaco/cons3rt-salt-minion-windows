@ECHO OFF

REM !/bin/bash
REM
REM install-salt-minion.bat
REM
REM Prepared by: Joseph Yennaco
REM Contact: Joe.Yennaco@pci-sm.com
REM PCI Strategic Management, LLC
REM 15 New England Executive Park REM2106
REM Burlington, MA 01803
REM
REM Date: 28 February 2014
REM
REM Purpose: This script calls a powershell script to install Salt Minion.
REM
REM Prerequisites:
REM 	-- Internet connectivity (Salt Minion is not in the media directory)
REM  	-- Run this script as an admin user
REM 

echo "### INFO: Running install-salt-minion.bat ..."

set POWERSHELL_SCRIPT="install-salt-minion.ps1"
set URL="http://docs.saltstack.com/downloads"
set INSTALLER="Salt-Minion-2014.1.0-AMD64-Setup.exe"

echo "### INFO: Printing the environment ..."
echo "############################"
set
echo "############################"
echo "### INFO: DEPLOYMENT_HOME: %DEPLOYMENT_HOME%"
echo "### INFO: ASSET_DIR: %ASSET_DIR%"
echo "### INFO: URL: %URL%"
echo "### INFO: INSTALLER: %INSTALLER%"
echo "### INFO: CD: %CD%"
echo "### INFO: POWERSHELL_SCRIPT: %POWERSHELL_SCRIPT%"

echo "### INFO: Running Powershell ..."

REM -- Invoke the Powershell script
start /wait powershell -NoLogo -Noninteractive -ExecutionPolicy Bypass -File %CD%\\%POWERSHELL_SCRIPT% %ASSET_DIR% %URL% %INSTALLER% %DEPLOYMENT_HOME%

echo "### INFO: Powershell Done."
echo "### INFO: install-salt-minion.bat complete."
