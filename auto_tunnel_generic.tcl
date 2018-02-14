#!/usr/bin/expect

##############################
# Name: auto_login 
# Author: pdelevor@DOMAIN.com
# Description: Automatic login to DMZ 
#              hosts through jump host, 
#              optional sudo to httpd
# Revision: 0.1 
# Date: 6/1/11
##############################


#aliases
 
set hosts_byname(SERVER_PREFIX01) SERVER_PREFIX01.DOMAIN.com
set hosts_byname(SERVER_PREFIX02) SERVER_PREFIX02.DOMAIN.com
set hosts_byname(SERVER_PREFIX03) SERVER_PREFIX03.DOMAIN.com
set hosts_byname(SERVER_PREFIX04) SERVER_PREFIX04.DOMAIN.com
set hosts_byname(SERVER_PREFIX05) SERVER_PREFIX05.DOMAIN.com
set hosts_byname(SERVER_PREFIX06) SERVER_PREFIX06.DOMAIN.com
set hosts_byname(SERVER_PREFIX07) SERVER_PREFIX07.DOMAIN.com
set hosts_byname(SERVER_PREFIX08) SERVER_PREFIX08.DOMAIN.com
set hosts_byname(SERVER_PREFIX09) SERVER_PREFIX09.DOMAIN.com
set hosts_byname(SERVER_PREFIX10) SERVER_PREFIX10.DOMAIN.com
set hosts_byname(SERVER_PREFIX11) SERVER_PREFIX11.DOMAIN.com
set hosts_byname(SERVER_PREFIX12) SERVER_PREFIX12.DOMAIN.com
set hosts_byname(SERVER_PREFIX13) SERVER_PREFIX13.DOMAIN.com
set hosts_byname(SERVER_PREFIX14) SERVER_PREFIX14.DOMAIN.com
set hosts_byname(SERVER_PREFIX15) SERVER_PREFIX15.DOMAIN.com
set hosts_byname(SERVER_PREFIX16) SERVER_PREFIX16.DOMAIN.com
set hosts_byname(SERVER_PREFIX17) SERVER_PREFIX17.DOMAIN.com
set hosts_byname(SERVER_PREFIX18) SERVER_PREFIX18.DOMAIN.com
set hosts_byname(SERVER_PREFIX19) SERVER_PREFIX19.DOMAIN.com
set hosts_byname(SERVER_PREFIX20) SERVER_PREFIX20.DOMAIN.com
set hosts_byname(SERVER_PREFIX21) SERVER_PREFIX21.DOMAIN.com
set hosts_byname(SERVER_PREFIX22) SERVER_PREFIX22.DOMAIN.com

set hosts_indexed(01) SERVER_PREFIX01.DOMAIN.com
set hosts_indexed(02) SERVER_PREFIX02.DOMAIN.com
set hosts_indexed(03) SERVER_PREFIX03.DOMAIN.com
set hosts_indexed(04) SERVER_PREFIX04.DOMAIN.com
set hosts_indexed(05) SERVER_PREFIX05.DOMAIN.com
set hosts_indexed(06) SERVER_PREFIX06.DOMAIN.com
set hosts_indexed(07) SERVER_PREFIX07.DOMAIN.com
set hosts_indexed(08) SERVER_PREFIX08.DOMAIN.com
set hosts_indexed(09) SERVER_PREFIX09.DOMAIN.com
set hosts_indexed(10) SERVER_PREFIX10.DOMAIN.com
set hosts_indexed(11) SERVER_PREFIX11.DOMAIN.com
set hosts_indexed(12) SERVER_PREFIX12.DOMAIN.com
set hosts_indexed(13) SERVER_PREFIX13.DOMAIN.com
set hosts_indexed(14) SERVER_PREFIX14.DOMAIN.com
set hosts_indexed(15) SERVER_PREFIX15.DOMAIN.com
set hosts_indexed(16) SERVER_PREFIX16.DOMAIN.com
set hosts_indexed(17) SERVER_PREFIX17.DOMAIN.com
set hosts_indexed(18) SERVER_PREFIX18.DOMAIN.com
set hosts_indexed(19) SERVER_PREFIX19.DOMAIN.com
set hosts_indexed(20) SERVER_PREFIX20.DOMAIN.com
set hosts_indexed(21) SERVER_PREFIX21.DOMAIN.com
set hosts_indexed(22) SERVER_PREFIX22.DOMAIN.com
set hosts_indexed(23) SERVER_PREFIX23.DOMAIN.com
set hosts_indexed(jump) JUMP_SERVER_PREFIX02.DOMAIN.com 

set no_jump {    
    "SERVER_PREFIX03.DOMAIN.com"
    "SERVER_PREFIX03"
}

#set hosts_indexed(jump) SERVER_PREFIX02.DOMAIN.com 

# vars

set shell_id 0 
set prompt " "
set host ""
set pass ""
set sudo_user httpd
set do_sudo n
set jump_only false
set STARTING_PORT 22000
set SSH_PORT 22

proc banner { } {
    global argv0
    set prgname [split $argv0 "/"]
    set len [llength $prgname]
puts "#############################################"
#puts "[lindex $prgname  $len - 1  ]" 
puts "$argv0"
puts "[exec date]"
puts "For help: $argv0 help"
puts "#############################################\n"
}

proc help { } {
    global argv argv0
# Name: auto_login 
# Author: pdelevor@DOMAIN.com
# Description: Automatic login to DMZ 
#              hosts through jump host, 
#              optional sudo to httpd
# Revision: 0.1 
# Date: 6/1/11

send_user "\rUsage: $argv0 \[ host alias or host name \]\n\n\r"

send_user "\rTo turn interactive sudo option off, set and export environment variable NO_SUDO\n\r"

}

proc get_next_port { } {

 global STARTING_PORT SSH_POR
 # TCP    [::1]:22000            DG30CCRM1:0            LISTENING
 
 set fd [ open "|netstat -a" "r"]
 set netstat_out [ read $fd ]
 close $fd
 set out_list [ split $netstat_out "\n" ]
 set start_port $STARTING_PORT
 foreach line $out_list {

    # TCP    127.0.0.1:22000        DG30CCRM1:0            LISTENING

    regsub -all {[ ]+} $line { } trimmed     
    # TCP 127.0.0.1:22000 DG30CCRM1:0 LISTENING

    # check for list containing starting port and "LISTENING"
    if { [lsearch -all $trimmed 127.0.0.1:$start_port] == 1 && [lsearch -all $trimmed "LISTENING"] == 3 } {
        # contains a match, increment port
        incr start_port
    } 
 }
 # start_port is next port
 return $start_port
}
proc do_tunnel { host pass ssh_port final } {

    global shell_id env SSH_PORT

    # if final == true, attach the ssh port to port 22
    #  TCP    127.0.0.1:22000        DG30CCRM1:0            LISTENING
    #  TCP    [::1]:22000            DG30CCRM1:0            LISTENING
    # Local desktop:
    # ssh -L22000:localhost:22000 SERVER_PREFIX02
    # Jump Host:
    # ssh -L 22000:localhost:22000 SERVER_PREFIX03
    # SERVER_PREFIX03:
    # ssh -L 22000:localhost:22 SERVER_PREFIX03

    # 1. generate new port for tunnel

    set pass_count 0

    set spwan_id $shell_id
    send_user "\n\rLogging into host $host\n\r" 

    if { $final == "true" } {
        send_user "\rssh -L${ssh_port}:localhost:${SSH_PORT} $host\r"    
        send "ssh -L${ssh_port}:localhost:${SSH_PORT} $host\r"    
    } else {
        send_user "\rssh -L${ssh_port}:localhost:${ssh_port} $host\r"    
        send "ssh -L${ssh_port}:localhost:${ssh_port} $host\r"    
    }

    expect {
            "yes/no" { send "yes\r" ; exp_continue }
            "password: " { 
                    if { $pass_count > 0 } {
                        send_user "Uh-oh, bad password!\r\n"    
                        send_user "Enter another try: "
                        flush stdout
                        stty -echo
                        gets stdin pass
                        stty echo
                        send_user "\r\nTrying new password ..\r\n"
                    }
                    send "$pass\r" ; 
                    incr pass_count; 
                    exp_continue 
            }
            "\$ " { 
		    send_user "\r\nSet tunnel for $host using port $ssh_port\r\n" 
            }


    }
    sleep 2
    if { $final == "true" } {
	    set ssh_script "/tmp/auto_tunnel.ksh"
	    set fd [ open $ssh_script a+ 0755 ]
	    if { [file exists $ssh_script] != 1 } {
		    puts $fd "#!/bin/ksh"
	    }
	    puts $fd "echo [exec date]"
	    puts $fd "echo \"Tunnel for $host:\""
	    puts $fd "echo \"ssh -p $ssh_port localhost\""
	    close $fd
	    send_user "\r\nport mapping script: $ssh_script\r\n"

    }
}

# ssh login proc 
proc do_login { host pass } {
    global shell_id  env 
    set pass_count 0

    set spwan_id $shell_id
    send_user "\n\rLogging into host $host\n\r" 
    send "ssh $host\r"    
    expect {
            "yes/no" { send "yes\r" ; exp_continue }
            "password: " { 
                    if { $pass_count > 0 } {
                        send_user "Uh-oh, bad password!\r\n"    
                        send_user "Enter another try: "
                        flush stdout
                        stty -echo
                        gets stdin pass
                        stty echo
                        send_user "\r\nTrying new password ..\r\n"
                    }
                    send "$pass\r" ; 
                    incr pass_count; 
                    exp_continue 
            }
            "\$ " { send_user "\n\rLogged into $host as $env(USER)\n\r" }
    }
    sleep 2

}

# sudo proc
proc do_sudo { pass } {
    global shell_id host hosts_indexed sudo_user user
    set pass_count 0
    set this_host ""
    if { [lsearch [array names hosts_indexed] $host] != -1 } {
        set this_host $hosts_indexed($host) 
    } else {
        set this_host $host 
    } 
    set spwan_id $shell_id
    send "sudo su - $sudo_user\r"
    expect {
            "assword:" { 
                    if { $pass_count > 0 } {
                        send_user "Uh-oh, bad password!\r\n"    
                        send_user "Enter sudo another try: "
                        flush stdout
                        stty -echo
                        gets stdin pass
                        stty echo
                        send_user "\r\nTrying new password ..\r\n"
                    }
                    send "$pass\r" 
                    incr pass_count; 
                    exp_continue 
            }
            "assword: " { 
                    if { $pass_count > 0 } {
                        send_user "Uh-oh, bad password!\r\n"    
                        send_user "Enter sudo another try: "
                        flush stdout
                        stty -echo
                        gets stdin pass
                        stty echo
                        send_user "\r\nTrying new password ..\r\n"
                    }
                    send "$pass\r" 
                    incr pass_count; 
                    exp_continue 
            }
            "password for $user: " { 
                    if { $pass_count > 0 } {
                        send_user "Uh-oh, bad password!\r\n"    
                        send_user "Enter sudo another try: "
                        flush stdout
                        stty -echo
                        gets stdin pass
                        stty echo
                        send_user "\r\nTrying new password ..\r\n"
                    }
                    send "$pass\r" 
                    incr pass_count; 
                    exp_continue 
            }

            "\$ " { 
                flush stdout
                send_user "\rSudo to $sudo_user on $this_host\n" 
            }
    }
    send "cd ~/sustain_bin; . sustain_env.ksh\r"
    expect "\$ " 

}

proc view_aliases { } {
    global hosts_indexed
    send_user "Host aliases:\n"
    foreach  { alias }   [lsort -dictionary [array names hosts_indexed]]  {
         send_user "$alias  -> $hosts_indexed($alias)\n"
    }
}

proc get_sudo_option { } {
    global do_sudo sudo_user env
    log_user 1
    if { [lsearch [array names env] NO_SUDO] == -1  } {
    while { 1 } {
            send_user "\n\rsudo to $sudo_user? \[y/n\]: "
            flush stdout
            gets stdin do_sudo
            send_user "\n\r"
            if { $do_sudo == "y" || $do_sudo == "n" } { break }
        } 
    }
}


##############################
# BEGIN MAIN
##############################
banner
##############################

# Check args host, pass

if { [llength $argv] == 1 } {
    if { [lindex $argv 0] == "help" } {
        help
        exit
    }
    if { [lindex $argv 0] == "jump" } {
        set jump_only true
    }
    set host [lindex $argv 0]
    send_user "Password: "
    flush stdout
    stty -echo
    gets stdin pass
    stty echo
} else { 
    view_aliases
    # JUMP LOGIN
    send_user "\nEnter alias #1-[array size hosts_indexed] or hostname: "
    flush stdout
    gets stdin host
    send_user "Password: "
    flush stdout
    stty -echo
    gets stdin pass
    stty echo
}

#get_sudo_option

set user $env(USER) 

log_user 0
spawn /bin/sh
set shell_id $spawn_id
expect "\$ "
send "export PS1=$prompt\r"
expect $prompt 
sleep 1
log_user 1

#set jump  "${user}@SERVER_PREFIX02.DOMAIN.com"
set jump  "${user}@jump.DOMAIN.com"
send_user "Using Jump host $jump\r\n"

set ssh_port [get_next_port] 
send_user "Set ssh port $ssh_port\r\n"

send_user "\r\ngenerated new port $ssh_port for tunnel\r\n"

if { 
    [lsearch $no_jump $host] == -1 && 
    [lsearch $no_jump $hosts_indexed($host)] == -1 
} {
    send_user "\r\n$host not found in no-jump list\r\n"
    if { $jump_only == "true" } {
        do_tunnel $jump $pass $SSH_PORT true
    } else {
        do_tunnel $jump $pass $ssh_port false
    }
}

if { $jump_only == "false" } {

    # check if in array
    if { [lsearch [array names hosts_indexed] $host] != -1 } {
        set host $hosts_indexed($host)
    } 
    do_tunnel $host $pass $ssh_port false
    do_tunnel $host $pass $ssh_port true

}

send_user "\n\rPress return for a prompt\n\r"
interact


