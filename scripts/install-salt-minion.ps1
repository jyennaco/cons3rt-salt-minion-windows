#
# Prepared by: Joseph Yennaco
# PCI Strategic Management, LLC
# 15 New England Executive Park #2106
# Burlington, MA 01803
# 
# Prepared for: DCGS MET Office (DMO)
# 11 Barksdale Street
# Hanscom AFB, MA 01731
#
# Date: 23 January 2014
#
# Purpose: This script installs and starts the CTE in InMemory mode.
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

# Local variables for the log file
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
		echo "### INFO: done.`n"
	}
	else {
		echo "### INFO: The media file $INSTALLER was found in $MEDIA_SHARE, copying over to $CONS3RT_DIR ...`n"
		Copy-Item $MEDIA_SHARE\$INSTALLER $CONS3RT_DIR\ -recurse -force
		echo "### INFO: done.`n"
	}
	
	# Exit if the value for ASSET_DIR is not set
	if ( !$DEPLOYMENT_HOME ) {
		echo "### INFO: DEPLOYMENT_HOME is not set. Cannot read salt-master from runtime properties.`n"
	}
	else {
		echo "### INFO: DEPLOYMENT_HOME set."
		
		# Exit if the install media can't be found
		if ( !(test-path $DEPLOYMENT_HOME\fap-deployment.properties) ) {
			echo "### ERROR: DEPLOYMENT _HOME was set but the fap-deployment.properties file was not found in $DEPLOYMENT_HOME.  Cannot determine salt-master from runtime properties.  Salt Minion will not be installed, but can be installed manually from $CONS3RT_DIR.  Exiting ...`n"
			exit
		}
		
		
		$saltMaster = Get-Content $propFile | Select-String "salt-master" | foreach {$d = $_ -split "="; Write-Output $d[1] }
	}
	
	
	# Location of Deployment properties file
	$propFile="$DEPLOYMENT_HOME/fap-deployment.properties"
	
	
	

	

	
	# Create the install directories if they doesn't exist
	echo "Checking if $INST_ROOT directory exists ... "
	if ( !(test-path $INST_ROOT) ) {
		echo "Creating the $INST_ROOT directory ... "
		New-Item -name tools -path "$INST_ROOT\" -itemType directory -force
		echo "done.`n"
	}
	else {
		echo "The $INST_ROOT directory already exists.`n"
	}
	
	########## CTE SERVER INSTALLATION ##########
	
	echo "Installing the CTE Web Server ... `n"
	
	# Exit if the install media can't be found
	if ( !(test-path $MEDIA_SHARE\$DEVTOOL_INSTALLER) ) {
		echo "### ERROR: The media file $DEVTOOL_INSTALLER not found in $MEDIA_SHARE.  Exiting...`n"
		exit
	}
	
	# Copying the CTE file to $INST_ROOT
	echo "Copying the $MEDIA_SHARE\$DEVTOOL_INSTALLER directory to $INST_ROOT\ ... "
	Copy-Item $MEDIA_SHARE\$DEVTOOL_INSTALLER $INST_ROOT\ -recurse -force
	echo "done.`n"
	
	# Exit if the install media can't be found
	if ( !(test-path $INST_ROOT\$DEVTOOL_INSTALLER) ) {
		echo "### ERROR: The media file $DEVTOOL_INSTALLER not found in $INST_ROOT.  The file must not have copied correctly.  Exiting...`n"
		exit
	}
	
	# Unziping the CTE installer
	echo "Unzipping the $INST_ROOT\$DEVTOOL_INSTALLER to $INST_ROOT\ ... "
	$unzipSuccess=unzip "$INST_ROOT\$DEVTOOL_INSTALLER" "$INST_ROOT\"
	
	# Exit if unzipped was not successful
	if ( $unzipSuccess -eq 0 ) {
		echo "### ERROR: $DEVTOOL_INSTALLER was not able to be unzipped.  Exiting..."
		exit
	}
	echo "done.`n"
	
	# Exit if the install media can't be found
	if ( !(test-path $MEDIA_SHARE\$OPT_INSTALLER) ) {
		echo "### ERROR: The media file $OPT_INSTALLER not found in $MEDIA_SHARE.  Exiting...`n"
		exit
	}
	
	# Copying the CTE opt directories to $INST_ROOT
	echo "Copying the $MEDIA_SHARE\$OPT_INSTALLER directory to $INST_ROOT\ ... "
	Copy-Item $MEDIA_SHARE\$OPT_INSTALLER $INST_ROOT\ -recurse -force
	echo "done.`n"
	
	# Exit if the install media can't be found
	if ( !(test-path $INST_ROOT\$OPT_INSTALLER) ) {
		echo "### ERROR: The media file $OPT_INSTALLER not found in $INST_ROOT.  The file must not have copied correctly.  Exiting...`n"
		exit
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
