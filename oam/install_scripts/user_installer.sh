#!/usr/bin/expect
#
# $Id: user_installer.sh 1066 20081113 21:44:44Z dhill $
#
# Install RPM and custom OS files on system
# Argument 1 - Remote Module Name
# Argument 2 - Remote Server Host Name or IP address
# Argument 3 - Root Password of remote server
# Argument 4 - Package name being installed
# Argument 5 - Install Type, "initial" or "upgrade"
# Argument 6 - Debug flag 1 for on, 0 for off
set timeout 30
set USERNAME root
set MODULE [lindex $argv 0]
set SERVER [lindex $argv 1]
set PASSWORD [lindex $argv 2]
set CALPONTRPM [lindex $argv 3]
set CALPONTMYSQLRPM [lindex $argv 4]
set CALPONTMYSQLDRPM [lindex $argv 5]
set INSTALLTYPE [lindex $argv 6]
set PKGTYPE [lindex $argv 7]
set NODEPS [lindex $argv 8]
set MYSQLPW [lindex $argv 9]
set DEBUG [lindex $argv 10]
set INSTALLDIR "/usr/local/Calpont"
set IDIR [lindex $argv 11]
if { $IDIR != "" } {
	set INSTALLDIR $IDIR
}
set USERNAME "root"
set UNM [lindex $argv 12]
if { $UNM != "" } {
	set USERNAME $UNM
}

if { $MYSQLPW == "none" } {
	set MYSQLPW " "
} 

set BASH "/bin/bash "
if { $DEBUG == "1" } {
	set BASH "/bin/bash -x "
}

log_user $DEBUG
spawn -noecho /bin/bash
#
if { $PKGTYPE == "rpm" } {
	set PKGERASE "rpm -e --nodeps --allmatches "
	set PKGINSTALL "rpm -ivh $NODEPS "
	set PKGUPGRADE "rpm -Uvh --noscripts "
} else {
	if { $PKGTYPE == "deb" } {
		set PKGERASE "dpkg -P "
		set PKGINSTALL "dpkg -i --force-confnew"
		set PKGUPGRADE "dpkg -i --force-confnew"
	} else {
		send_user "Invalid Package Type of $PKGTYPE"
		exit 1
	}
}

# check and see if remote server has ssh keys setup, set PASSWORD if so
send_user " "
send "ssh $USERNAME@$SERVER 'time'\n"
set timeout 60
expect {
	-re "Host key verification failed" { send_user "FAILED: Host key verification failed\n" ; exit 1 }
	-re "service not known" { send_user "FAILED: Invalid Host\n" ; exit 1 }
	-re "authenticity" { send "yes\n" 
						expect {
							-re "word: " { send "$PASSWORD\n" } abort
							-re "passphrase" { send "$PASSWORD\n" } abort
						}
	}
	-re "sys" { set PASSWORD "ssh" } abort
	-re "word: " { send "$PASSWORD\n" } abort
	-re "passphrase" { send "$PASSWORD\n" } abort
	-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
	-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
	-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
	-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	timeout { send_user "ERROR: Timeout to host\n" ; exit 1 }
}
set timeout 30
expect {
	-re "# "        {  } abort
	-re "sys" {  } abort
}
send_user "\n"
#BUG 5749 - SAS: didn't work on their system until I added the sleep 60
sleep 60

if { $INSTALLTYPE == "initial" || $INSTALLTYPE == "uninstall" } {
	# 
	# erase Calpont-mysql package
	#
	send_user "Erase calpont-mysql Package on Module           "
	send "ssh $USERNAME@$SERVER '$PKGERASE calpont-mysql'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "# "                  { send_user "DONE" } abort
		-re "uninstall completed" { send_user "DONE" } abort
		-re "removing" { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "not installed"       { send_user "INFO: Package not installed" } abort
		-re "isn't installed"       { send_user "INFO: Package not installed" } abort
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	# 
	# erase Calpont-mysqld package
	#
	send_user "Erase calpont-mysqld Package on Module          "
	set timeout 30
	expect -re "# "
	send "ssh $USERNAME@$SERVER '$PKGERASE  calpont-mysqld'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "# "                  { send_user "DONE" } abort
		-re "uninstall completed" { send_user "DONE" } abort
		-re "removing" { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "not installed"       { send_user "INFO: Package not installed" } abort
		-re "isn't installed"       { send_user "INFO: Package not installed" } abort
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	# 
	# erase Calpont package
	#
	send_user "Erase calpont Package on Module                 "
	set timeout 30
	expect -re "# "
	send "ssh $USERNAME@$SERVER '$PKGERASE  calpont'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "# "                  { send_user "DONE" } abort
		-re "uninstall completed" { send_user "DONE" } abort
		-re "removing" { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "not installed"       { send_user "INFO: Package not installed" } abort
		-re "isn't installed"       { send_user "INFO: Package not installed" } abort
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
}
if { $INSTALLTYPE == "uninstall" } { exit 0 }

# 
# send the Calpont package
#
set timeout 30
expect -re "# "
send_user "Copy new calpont Package to Module              "
#gives time for the rpmsave to be done
sleep 5
send "ssh $USERNAME@$SERVER 'rm -f /root/calpont*.$PKGTYPE'\n"
if { $PASSWORD != "ssh" } {
	set timeout 30
	expect {
		-re "word: " { send "$PASSWORD\n" } abort
		-re "passphrase" { send "$PASSWORD\n" } abort
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
}
set timeout 30
expect {
	-re "# " { } abort
}
send "scp $CALPONTRPM  $USERNAME@$SERVER:$CALPONTRPM\n"
if { $PASSWORD != "ssh" } {
	set timeout 30
	expect {
		-re "word: " { send "$PASSWORD\n" } abort
		-re "passphrase" { send "$PASSWORD\n" } abort
	}
}
set timeout 120
expect {
	-re "100%" 				{ send_user "DONE" } abort
	-re "directory"  		{ send_user "ERROR\n" ; 
				 			send_user "\n*** Installation ERROR\n" ; 
							exit 1 }
	-re "Permission denied, please try again"         { send_user "ERROR: Invalid password\n" ; exit 1 }
	-re "No such file or directory" { send_user "ERROR: Invalid package\n" ; exit 1 }
	-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
	-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
	-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
}
send_user "\n"
#sleep to make sure it's finished
sleep 5
# 
# send the package
#
send_user "Copy new calpont-mysql Package to Module        "
send "scp $CALPONTMYSQLRPM  $USERNAME@$SERVER:$CALPONTMYSQLRPM\n"
if { $PASSWORD != "ssh" } {
	set timeout 30
	expect {
		-re "word: " { send "$PASSWORD\n" } abort
		-re "passphrase" { send "$PASSWORD\n" } abort
	}
}
set timeout 120
expect {
	-re "100%" 				{ send_user "DONE" } abort
	-re "directory"  		{ send_user "ERROR\n" ; 
				 			send_user "\n*** Installation ERROR\n" ; 
							exit 1 }
	-re "Permission denied, please try again"         { send_user "ERROR: Invalid password\n" ; exit 1 }
	-re "No such file or directory" { send_user "ERROR: Invalid package\n" ; exit 1 }
	-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
	-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
	-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
}
send_user "\n"
#sleep to make sure it's finished
sleep 5
# 
# send the package
#
send_user "Copy new calpont-mysqld Package to Module       "
send "scp $CALPONTMYSQLDRPM  $USERNAME@$SERVER:$CALPONTMYSQLDRPM\n"
if { $PASSWORD != "ssh" } {
	set timeout 30
	expect {
		-re "word: " { send "$PASSWORD\n" } abort
		-re "passphrase" { send "$PASSWORD\n" } abort
	}
}
set timeout 120
expect {
	-re "100%" 				{ send_user "DONE" } abort
	-re "directory"  		{ send_user "ERROR\n" ; 
				 			send_user "\n*** Installation ERROR\n" ; 
							exit 1 }
	-re "Permission denied, please try again"         { send_user "ERROR: Invalid password\n" ; exit 1 }
	-re "No such file or directory" { send_user "ERROR: Invalid package\n" ; exit 1 }
	-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
	-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
	-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
}
send_user "\n"
#sleep to make sure it's finished
sleep 5
#
set timeout 30
expect -re "# "
if { $INSTALLTYPE == "initial"} {
	#
	# install package
	#
	send_user "Install calpont Package on Module               "
	send "ssh $USERNAME@$SERVER '$PKGINSTALL $CALPONTRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "# " 		  		  { send_user "DONE" } abort
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
	#
	# install package
	#
	send_user "Install calpont-mysqld Package on Module        "
	send "ssh $USERNAME@$SERVER '$PKGINSTALL $CALPONTMYSQLDRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
	#
	# install package
	#
	send_user "Install calpont-mysql Package on Module         "
	send "ssh $USERNAME@$SERVER '$PKGINSTALL $CALPONTMYSQLRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
} else {
	#
	# upgrade package
	#
	expect -re "# "
	send_user "Upgrade calpont Package on Module               "
	send "ssh $USERNAME@$SERVER '$PKGUPGRADE $CALPONTRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "already installed"   { send_user "INFO: Already Installed\n" ; exit 1 }
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
	#
	# upgrade package
	#
	send_user "Upgrade calpont-mysqld Package on Module        "
	send "ssh $USERNAME@$SERVER '$PKGUPGRADE  $CALPONTMYSQLDRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "already installed"   { send_user "INFO: Already Installed\n" ; exit 1 }
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
	#
	# upgrade package
	#
	send_user "Upgrade calpont-mysql Package on Module         "
	send "ssh $USERNAME@$SERVER '$PKGUPGRADE  $CALPONTMYSQLRPM'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "completed" 		  { send_user "DONE" } abort
		-re "Setting up" 		  { send_user "DONE" } abort
		-re "already installed"   { send_user "INFO: Already Installed\n" ; exit 1 }
		-re "error: Failed dependencies" { send_user "ERROR: Failed dependencies\n" ; 
									send_user "\n*** Installation ERROR\n" ; 
										exit 1 }
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
}
#
#sleep to make sure rpm install has finsihed
sleep 10
if { $INSTALLTYPE == "initial"} {
	#
	# copy over calpont config file
	#
	send_user "Copy Calpont Config file to Module              "
	send "scp $INSTALLDIR/etc/*  $USERNAME@$SERVER:$INSTALLDIR/etc/.\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "directory"  		{ send_user "ERROR\n" ; 
								send_user "\n*** Installation ERROR\n" ; 
								exit 1 }
		-re "# " 		  		  { send_user "DONE" } abort
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	#sleep to make sure it's finished
	sleep 5
	#
	# copy over custom OS tmp files
	#
	send_user "Copy Custom OS files to Module                  "
	send "scp -r $INSTALLDIR/local/etc  $USERNAME@$SERVER:$INSTALLDIR/local/.\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "directory"  		{ send_user "ERROR\n" ; 
								send_user "\n*** Installation ERROR\n" ; 
								exit 1 }
		-re "# " 		  		  { send_user "DONE" } abort
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	#sleep to make sure it's finished
	sleep 5
	#
	# copy over calpont OS files
	#
	send_user "Copy Calpont OS files to Module                 "
	send "scp $INSTALLDIR/local/etc/$MODULE/*  $USERNAME@$SERVER:$INSTALLDIR/local/.\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "directory"  		{ send_user "ERROR\n" ; 
								send_user "\n*** Installation ERROR\n" ; 
								exit 1 }
		-re "# " 		  		  { send_user "DONE" } abort
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	#sleep to make sure it's finished
	sleep 5
	#
	# Start module installer to setup Custom OS files
	#
	send_user "Run Module Installer                            "
	send "ssh $USERNAME@$SERVER '$BASH $INSTALLDIR/bin/module_installer.sh um'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 30
	expect {
		-re "!!!Module" 				  			{ send_user "DONE" } abort
		-re "Permission denied, please try again"   { send_user "ERROR: Invalid password\n" ; exit 1 }
		-re "FAILED"   								{ send_user "ERROR: missing OS file\n" ; exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
	#
	# run mysql setup scripts
	#
	send_user "Run MySQL Setup Scripts on Module               "
	send "ssh $USERNAME@$SERVER '$BASH $INSTALLDIR/bin/post-mysqld-install'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 20
	expect {
		-re "ERROR" { send_user "ERROR: Daemon failed to run";
		exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	set timeout 30
	expect -re "# "
	#
	send "ssh $USERNAME@$SERVER '$BASH $INSTALLDIR/bin/post-mysql-install $MYSQLPW'\n"
	if { $PASSWORD != "ssh" } {
		set timeout 30
		expect {
			-re "word: " { send "$PASSWORD\n" } abort
			-re "passphrase" { send "$PASSWORD\n" } abort
		}
	}
	set timeout 60
	expect {
		-re "Shutting down mysql." { send_user "DONE" } abort
		-re "# " 	{ send_user "DONE" } abort
		timeout { send_user "DONE" } abort
		-re "ERROR" { send_user "ERROR: Daemon failed to run";
		exit 1 }
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
	}
	send_user "\n"
	set timeout 30
	expect -re "# "
}

#
# check InfiniDB syslog functionality
#

send_user "Check InfiniDB system logging functionality     "
send " \n"
send date\n
send "ssh $USERNAME@$SERVER '$BASH $INSTALLDIR/bin/syslogSetup.sh check'\n"
if { $PASSWORD != "ssh" } {
	set timeout 30
	expect {
		-re "word: " { send "$PASSWORD\n" } abort
		-re "passphrase" { send "$PASSWORD\n" } abort
	}
}
set timeout 30
expect {
	-re "Logging working" { send_user "DONE" } abort
	timeout { send_user "DONE" } abort
	-re "not working" { send_user "WARNING: InfiniDB system logging functionality not working" } abort
		-re "Connection refused"   { send_user "ERROR: Connection refused\n" ; exit 1 }
		-re "closed"   { send_user "ERROR: Connection closed\n" ; exit 1 }
		-re "No route to host"   { send_user "ERROR: No route to host\n" ; exit 1 }
}
send_user "\n"

send_user "\nInstallation Successfully Completed on '$MODULE'\n"
exit 0

