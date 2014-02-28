@ECHO OFF

REM !/bin/bash
REM
REM install-salt-master-centos6.sh
REM
REM Prepared by: Joseph Yennaco
REM Contact: Joe.Yennaco@pci-sm.com
REM PCI Strategic Management, LLC
REM 15 New England Executive Park REM2106
REM Burlington, MA 01803
REM
REM Date: 27 February 2014
REM
REM Purpose: This script calls a powershell script to install Salt Minion.
REM
REM Prerequisites:
REM 	-- Internet connectivity
REM  	-- Run this script as an admin user
REM 

set URL="http://docs.saltstack.com/downloads"
set INSTALLER="Salt-Minion-2014.1.0-AMD64-Setup.exe"

echo Running Powershell...

REM -- Invoke the Powershell script
start /wait powershell -NoLogo -Noninteractive -ExecutionPolicy Bypass -File %CD%\\%INSTALL_SCRIPT% %ASSET_DIR% %URL% %INSTALLER% %DEPLOYMENT_HOME%

echo Powershell Done...
