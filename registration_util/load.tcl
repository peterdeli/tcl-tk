
# AGNS:88522900:attbusiness.net:165.87.194.244:165.87.201.244:pap:1:
# DENVER800:18005904857:attbusiness.net:165.87.194.244:165.87.201.244:chap:1:
# ModemPool:3034662756::::swan::
# SWAN_56K:94185600::::swan:1:novj nocomp
# TEST:8001234567::::pap:1:ding
# jkhfkhf:875765:aaa.ccc.fff:1.2.3.4:5.4.3.2:pap:1:
# 
# 
# account  ModemPool
# ppp_uid  bongo
# password  
# init_string  file
# connect_string  file
# port_speed  38400
# flow_control  xonxoff
# modem_port  /dev/term/b

# name
# uid
# passwd
# number
# domain
# ns1
# ns2
# authtype
# defroute
# pppopts
# init_string
# connect_string
# port_speed
# flow_control
# modem_port

#Account format - single file

# load global settings
proc load_global { } {
	global ppp_dir

	set global_file "$ppp_dir/global_settings.cf"

}

proc load_accts { } {

	global env
	global ppp_dir
	# list
	global account_list
	# array (acct_name,key)
	global accounts
	# account file names
	global account_files
	global account_keys
	global account_dir

	if { [file isfile $account_dir] } { 
				puts "File $account_dir found, cannot create directory $account_dir"
	} elseif { [file exists $account_dir] != 1 } {
				puts "Creating account directory $account_dir"
				exec mkdir $account_dir
	}

	if { [file isdirectory $account_dir] } {
		cd $account_dir
		set files [exec ls]

		foreach file $files {
			if { [string match "*.cf" $file] == 1 } {
				puts "account file $file"
				lappend account_files $file
			}
		}

		if { [llength $account_files] < 1 } {

			puts "No account files"
			return 0

		} else {

			foreach acct $account_files {
				# open
				puts "open $acct"
				set acct_fd [open $acct r]
				puts "opened $acct"
				set acct_name [lindex [split $acct "."] 0]
				lappend account_list $acct_name
				set accounts($acct_name,name) $acct_name

				# parse into acct_array
				for { set i 0 } { [gets $acct_fd line] != -1 } {incr i} {
					set field [split $line "\t"]
					set key [lindex $field 0]
					string trim $key
					puts "Key=$key"
					set value [lindex $field 1]
					puts "Value $value"

					# check key
					if { [lsearch $account_keys $key] == -1 } {
						puts "Invalid key $key found in account file $acct"
						continue
					}

					# make sure account name is same as file prefix
					if { $key == "name" } {
						if {	$value == $acct_name } {
							continue	
						} else { 
							puts "Account name $value doesn't match account file name $acct_name"	
						}
					} else {
							set accounts($acct_name,$key) $value
					}
				}

				# next account file
				close $acct_fd
			}
			# done
			puts "Loaded accounts"

		}
	}

}

proc init { } {
	global env
	global ppp_dir
	# list
	global account_list
	set account_list {}

	# array (acct_name,key)
	global accounts
	
	# account file names
	global account_files
	set account_files ""

	global account_keys
	set account_keys {\
				 name\
				 uid\
				 passwd\
				 number\
				 domain\
				 ns1\
				 ns2\
				 authtype\
				 defroute\
				 pppopts\
				 init_string\
				 connect_string\
				 port_speed\
				 flow_control\
				 modem_port\
	}

	global account_dir
	set account_dir "$env(HOME)/.ppptool/ppp_accounts"
	set ppp_dir "$env(HOME)/.ppptool" 

}

init
load_accts
