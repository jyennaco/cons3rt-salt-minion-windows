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
	if ( !$DEPLOYMENT_HOME -or !(test-path $propFile) ) {"
		echo "### WARN: fap-deployment.properties file was not found in $DEPLOYMENT_HOME.  Cannot determine salt-master from role name or runtime properties."
		echo "### WARN: Salt Minion will not be automatically installed, but can be manually installed from $CONS3RT_DIR after logging in."
	}
	else {
		# Copy the fap-deployment.properties file to the $CONS3RT_DIR
		echo "### INFO: Copying fap-deployment.properties file to $CONS3RT_DIR for inspection after logging in ..."
		Copy-Item $propFile $CONS3RT_DIR\ -recurse -force
		
		# Grab the salt-master hostname or IP address if it exists
		$saltMaster = Get-Content $propFile | Select-String "salt-master" | foreach {$d = $_ -split "="; Write-Output $d[1] }
		
		# Check to see if salt-master was specified.  Note that Powershell is case insensitive.
		if ( !$saltMaster ) {
			echo "### WARN: fap-deployment.properties did not contain an entry for salt-master (case insensitive), not defined as a role name or runtime property."
			echo "### WARN: Salt Minion will not be automatically installed, but can be manually installed from $CONS3RT_DIR after logging in."
		}
		else {
			echo "### INFO: fap-deployment.properties contains a runtime property for salt-master: $saltMaster"
			echo "### INFO: Salt Minion for Windows will be installed with $saltMaster as the salt-master ..."
			$rand=GetRandom
			$minionName=minion-$rand
			$CONS3RT_DIR\$INSTALLER /S /master=$saltMaster /minion-name=$minionName
			echo "### INFO: done installing Salt Minion on Windows."
		}
	}
	
	echo "### INFO: Salt-Minion Install Script Complete.`n"
}

# Create the cons3rt directory
New-Item -name $CONS3RT_DIRNAME -path "$ROOT\" -itemType directory -force

# Create the log directory
New-Item -name $LOG_DIRNAME -path "$ROOT\CONS3RT_DIRNAME" -itemType directory -force

# Run the install function
echo "Running the install function ..."

install-salt-minion-windows 2>&1 >> $LOG_DIR\$LOGFILE

echo "Exiting..."
