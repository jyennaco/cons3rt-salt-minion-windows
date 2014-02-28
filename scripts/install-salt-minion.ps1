#
# install-salt-minion.ps1
#
# Prepared by: Joseph Yennaco
# PCI Strategic Management, LLC
# 15 New England Executive Park #2106
# Burlington, MA 01803
# 
# Date: 27 February 2014
#
# Purpose: This script downloads and installs the Salt Minion to Windows 
# 

# The value of ASSET_DIR provided by CONS3RT
$ASSET_DIR=$args[0]

# URL to download Salt Minion for Windows
$URL=$args[1]

# File name of the installer for Salt Minion for Windows
$INSTALLER=$args[2]

# The value of DEPLOYMENT_HOME provided by CONS3RT
$DEPLOYMENT_HOME=$args[3]

# Location of the INSTALLER if included.  If not included, this script will pull from the URL.
$MEDIA_SHARE="$pwd\..\media"

# Directory and log file variables
$TIMESTAMP=Get-Date -f yyyy-MM-dd-HHmm
$ROOT="C:"
$CONS3RT_DIRNAME="cons3rt"
$CONS3RT_DIR="$ROOT\$CONS3RT_DIRNAME"
$LOG_DIRNAME="log"
$LOG_DIR="$ROOT\$CONS3RT_DIRNAME\$LOG_DIRNAME"
$LOGFILE="cons3rt-install-salt-minion-windows-${TIMESTAMP}.log"
$SALT_OUT="cons3rt-install-salt-minion-windows-output-${TIMESTAMP}.log"
$SALT_ERR="cons3rt-install-salt-minion-windows-error-${TIMESTAMP}.log"


function install-salt-minion-windows {
	
	echo "### INFO: Installing Salt-Minion on Windows ...`n"
	echo "### INFO: Timestamp:`t`t$TIMESTAMP`n`n"
	echo "### INFO: ASSET_DIR:`t`t$ASSET_DIR`n"
	echo "### INFO: MEDIA_SHARE:`t`t$MEDIA_SHARE`n"
	echo "### INFO: INSTALLER:`t`t$INSTALLER`n"
	echo "### INFO: DEPLOYMENT_HOME:`t$DEPLOYMENT_HOME"
	
	echo "### INFO: Printing the environment ... `n"
	echo "#########################################"
	dir env:
	echo "#########################################"
	
	# Exit if the value for ASSET_DIR is not set
	if ( !$ASSET_DIR ) {
		echo "### ERROR: ASSET_DIR is not set.  Exiting...`n"
		exit
	}
	
	# Exit if the value for MEDIA_SHARE is not set
	if ( !$MEDIA_SHARE ) {
		echo "### ERROR: MEDIA_SHARE is not set.  Exiting...`n"
		exit
	}
	
	# Check if the installer is in the $MEDIA_SHARE directory
	if ( !(test-path $MEDIA_SHARE\$INSTALLER) ) {
		echo "### INFO: The media file $INSTALLER not found in $MEDIA_SHARE.  Attempting to download $INSTALLER from $URL ...`n"
		$client = new-object System.Net.WebClient
		$client.DownloadFile("$URL/$INSTALLER","$CONS3RT_DIR\$INSTALLER")
		echo "### INFO: done downloading $INSTALLER.`n"
	}
	else {
		echo "### INFO: The media file $INSTALLER was found in $MEDIA_SHARE, copying over to $CONS3RT_DIR ...`n"
		Copy-Item $MEDIA_SHARE\$INSTALLER $CONS3RT_DIR\ -recurse -force
		echo "### INFO: done.`n"
	}
	
	echo "### INFO: DEPLOYMENT_HOME: $DEPLOYMENT_HOME`n"
	
	# Location of Deployment properties file
	$propFile="$DEPLOYMENT_HOME/fap-deployment.properties"
	
	# Try to get salt-master IP/hostname from the fap-deployment.properties file
	if ( !$DEPLOYMENT_HOME -or !(test-path $propFile) ) {
		echo "### WARN: fap-deployment.properties file was not found in $DEPLOYMENT_HOME.  Cannot determine salt-master from role name or runtime properties."
		echo "### WARN: Salt Minion will not be automatically installed, but can be manually installed from $CONS3RT_DIR after logging in."
	}
	else {
		# Copy the fap-deployment.properties file to the $CONS3RT_DIR
		echo "### INFO: Copying fap-deployment.properties file to $CONS3RT_DIR for inspection after logging in ..."
		Copy-Item $propFile $CONS3RT_DIR\ -recurse -force
		
		# Grab the salt-master hostname or IP address if it stored written as a Cons3rt Scenario Role Name
		$saltMaster = Get-Content $propFile | Select-String "ipAddress.salt-master" | foreach {$d = $_ -split "="; Write-Output $d[1] }
		
		# If the IP address was not a Cons3rt Scenario Role Name, check if a Cons3rt Deployment Runtime Property was defined for salt-master
		if ( !$saltMaster ) {
			echo "### INFO: salt-master not found as a Scenario Role Name, checking for a Deployment Runtime Property for salt-master ... "
			$saltMaster = Get-Content $propFile | Select-String "salt-master" | foreach {$d = $_ -split "="; Write-Output $d[1] }
		}
		
		# Check to see if salt-master was specified, if not throw a warning and do not install Salt Minion.  Note that Powershell is case insensitive.
		if ( !$saltMaster ) {
			echo "### WARN: fap-deployment.properties did not contain an entry for salt-master (case insensitive), not defined as a role name or runtime property."
			echo "### WARN: Salt Minion will not be automatically installed, but can be manually installed from $CONS3RT_DIR after logging in."
		}
		else {
			echo "### INFO: fap-deployment.properties contains a runtime property for salt-master: $saltMaster"
			echo "### INFO: Salt Minion for Windows will be installed with $saltMaster as the salt-master ..."
			
			echo "### INFO: Checking to ensure the $INSTALLER is located in $CONS3RT_DIR ..."
			
			if ( !(test-path $CONS3RT_DIR\$INSTALLER) ) {
				echo "### ERROR: $INSTALLER not found in $CONS3RT_DIR.  Salt Minion will not be installed."
			}
			else {
				
				# Get the IP address of this system in order to get this system's Cons3rt Scenario Role Name
				echo "### INFO: Getting this system's IP address ..."
				$ipAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = "true"').ipaddress[0]
				echo "### INFO: IP address: $ipAddress"
				
				# Pull the Cons3rt Scenario Role name from the fap-deployment.properties file
				echo "### INFO: Attempting to get the Cons3rt Scenario Role name from $propFile ..."
				$rand=Get-Random
				$minionName="minion-$rand"
				
				# Install Salt Minion for Windows
				$installPath="$CONS3RT_DIR\$INSTALLER"
				$argList=@("/S", "/master=$saltMaster", "/minion-name=$minionName")
				echo "### INFO: Installing Salt Minion for Windows ..."
				Start-Process -FilePath $installPath -ArgumentList $argList -RedirectStandardOutput "$LOG_DIR\$SALT_OUT" -RedirectStandardError "$LOG_DIR\$SALT_ERR" -Wait
				echo "### INFO: done installing Salt Minion on Windows."
				
				# Start the salt-minion service
				echo "### INFO: Starting the salt-minion service ..."
				Start-Service salt-minion
				echo "### INFO: done."
			}
		}
	}
	
	echo "### INFO: Salt-Minion Install Script Complete.`n"
}

# Create the cons3rt directory
New-Item -name $CONS3RT_DIRNAME -path "$ROOT\" -itemType directory -force

# Create the log directory
New-Item -name $LOG_DIRNAME -path "$ROOT\$CONS3RT_DIRNAME" -itemType directory -force

# Run the install function
echo "Running the install function ..."

install-salt-minion-windows 2>&1 >> $LOG_DIR\$LOGFILE

echo "Exiting..."
