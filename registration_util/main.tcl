proc mainwin { } {

	build_menus

}

proc RandomInit { seed } {
        global randomSeed
        set randomSeed $seed
}
proc Random {} {
        global randomSeed
        set randomSeed [expr ($randomSeed*9301 + 49297) % 233280]
        return [expr $randomSeed/double(233280)]
}
proc RandomRange { range } {
        expr int([Random]*$range)
}

proc build_menus { } {

	##############################
	# Create GUI
	##############################

	#wm geometry . 500x250
	. configure -bg lightGray
	menu .menubar -bg lightGray

	# attach it to the main window
	. config -menu .menubar
	global active_account
	global accounts
	global connection_state
	global bulblist
	global bulbs
	global on_color
	global off_color
	global bulb_colors

	#set bulb_colors { yellow red green blue orange violet pink }
	#set bulb_colors { yellow red lightGreen black }
	set bulb_colors { black red #000000 }
	#set bulb_colors { black green red #000000 }
	set on_color [lindex $bulb_colors 0]
	set off_color [lindex $bulb_colors 1] 

	global after_intervals
	global after_interval
	set after_intervals { 250 250 250 10 10 10 10 250 250 250 10 10 10 10 300 300 300 500 500 500 } 
	set after_interval [lindex $after_intervals 0]

	set connection_state "connecting"

	###############################
	# Create more cascade menus
	###############################
	foreach m {File Edit Accounts Help} {

		# same as 'set File [ menu .. ]'
		set $m [menu .menubar.m$m]

		if { $m == "Help" } {
			# figure out how to put on the right side
			#.menubar add cascade -label "     " -menu .menubar.mFill 
			.menubar add cascade -label $m -menu .menubar.m$m 
		} else {
			.menubar add cascade -label $m -menu .menubar.m$m
		}
	}
	##############################
	# Add Menu Items
	##############################
	#puts "\$File = $File"
	$File add command -label "Save Settings" -command { puts "Save Settings" } 
	$File add command -label "View Log" -command { 

			view_log
	
	} 
	$File add command -label Quit -command exit

	#$Edit add command -label "Add Account" -command { puts "Add Account" }
	$Edit add command  -label "Manage Accounts" -command { 
		puts "Manage Accounts" 
		manage_accounts
	}
	$Edit add command -label "Edit Preferences" -command { 
		puts "Edit Preferences" 
		edit_prefs
	}

	$Help add command -label "About PPP Tool" -command { puts "About PPP Tool" }
	$Help add command -label "PPP Tool Help" -command { puts "PPP Tool Help" }

	frame .mid -bg lightGray

	label .acct_label -text "Active Account: No Account loaded" -relief groove -bg lightGray
	pack .acct_label -in .mid -fill x
	#label .color -text "Color" -bg white 
	#pack .color -in .mid

	pack .mid  -fill x

	# account window display
	#set no_acct_txt "No Account loaded"
	set no_acct_txt ""
	set acct_width 30
	set pad_val 3 
	set descr_bg lightGreen
	#	 name
	frame .namef  -bg lightGray
	label .namef.name_l -text "Account:" -bg $descr_bg -relief groove 
	label .namef.name_r -text $no_acct_txt -bg lightBlue -width $acct_width -relief groove 
	pack .namef.name_r -side right -pady [expr $pad_val * 2]
	pack .namef.name_l -side right -pady $pad_val
	.namef.name_r configure -anchor w
	#	 uid
	frame .uidf -bg lightGray
	label .uidf.uid_l -text "User ID:"  -bg $descr_bg -relief groove 
	entry .uidf.uid_r -text $no_acct_txt -bg lightYellow -width $acct_width  -relief groove 
	pack .uidf.uid_r -side right -pady $pad_val
	pack .uidf.uid_l -side right -pady $pad_val
	#.uidf.uid_r configure  -anchor w 

	#	 number
	frame .numberf -bg lightGray
	label .numberf.number_l -text "Phone Number:" -bg $descr_bg  -relief groove 
	label .numberf.number_r -text $no_acct_txt -bg lightBlue -width $acct_width  -relief groove 
	pack .numberf.number_r -side right -pady $pad_val
	pack .numberf.number_l -side right -pady $pad_val
	.numberf.number_r configure  -anchor w 
	#	 domain
	#	 ns1
	#	 ns2
	#	 authtype
	frame .authtypef -bg lightGray
	label .authtypef.authtype_l -text "Authentication Type: "  -bg $descr_bg -relief groove 
	label .authtypef.authtype_r -text $no_acct_txt  -bg lightBlue -width $acct_width  -relief groove 
	pack .authtypef.authtype_r -side right -pady $pad_val
	pack .authtypef.authtype_l -side right -pady [expr $pad_val * 2]
	.authtypef.authtype_r configure  -anchor w 


	pack .namef -in .mid -anchor w -fill x
	pack .uidf -in .mid -anchor w -fill x
	pack .numberf -in .mid -anchor w -fill x
	pack .authtypef -in .mid -anchor w -fill x

	frame .connect_frame -bg lightGray

	button .connect -text "Connect" -width 20 -state normal -command { 

		if { [.connect cget -text] == "Connect" } {
			.footer.footer_r configure -text "Connecting .."
			.connect configure -text "Disconnect"
			set connection_state "connecting"
			#blink_bulbs .cframe.can	0 right
			init_blinking_bulbs
		} else {
			.footer.footer_r configure -text "No connection"
			.connect configure -text "Connect"
			set connection_state "disconnected"
		}
	
	}

	if { [info exists active_account] != 1 } {
		.connect configure -state disabled
	}

	pack .connect -in .connect_frame
	pack .connect_frame -pady 10

	frame .cframe -bg lightGray
	canvas .cframe.can -width 220 -height 20  -bg lightGray

	set x1 5 
	set y1 5
	set x2 15
	set y2 15
	foreach can_oval { 0 1 2 3 4 5 6 7 8 9 10 11 } {
		.cframe.can create oval $x1 $y1 $x2 $y2 -fill red -width 2 -tag "bulb[set can_oval]"
		incr x1 18 
		set x2 [expr $x1 + 10]	
		lappend bulblist "bulb[set can_oval]"
		set bulbs(bulb[set can_oval],color) [lindex $bulb_colors 0]
		#puts "set bulbs(bulb[set can_oval],color) [lindex $bulb_colors 0]"
		#puts "bulbs(bulb[set can_oval],color) == $bulbs(bulb[set can_oval],color)" 
	}
	pack .cframe.can
	pack .cframe 

	frame .modembutton_text
	foreach modem_text { HS AA CD OH RD SD TR MR RS CS SYN FAX } {
		label .modembutton_text._$modem_text -text $modem_text -bg black -fg white -font {times 6}
		pack .modembutton_text._$modem_text -side left
	}
	pack .modembutton_text 

	#pppopts
	# init_string
	# connect_string
	# port_speed
	# flow_control
	# modem_port

	frame .footer -bg lightGray
	label .footer.footer_l -text "Status:" -relief groove -bg lightGray
	label .footer.footer_r -text "No connection" -relief groove -bg lightGray
	pack .footer.footer_l -side left 
	pack .footer.footer_r -side left -fill x -expand 1
	.footer.footer_r configure -anchor w	
	pack .footer -anchor s -side bottom -fill x -expand 1

	global menubar_widget
	set menubar_widget .menubar 
	global acct_widget
	set acct_widget $Accounts

	add_accounts


}

proc save_settings { } {

	##  compare tmp file to actual file
	global accounts
	global
	global ppp_settings
	global env
	global ppp_dir
	set ppp_dir "$env(HOME)/.ppptool" 
	global ppp_config_file
	set ppp_config_file "$ppp_dir/ppp_settings"
	# list
	global active_account
	global account_list
	set account_list {}

	# array (account_name,key)
	global accounts
	
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
	}

	global account_file
	set account_file "$ppp_dir/accounts"
	# read existing account file,
	# load info into 'tmp_accounts'
	# set tmp_account list

	##  save current settings to tmp file
	set tmp_account_file "[set account_file].tmp"
	# write accounts array to file
	foreach account $account_list {

	}
	# read accounts file
	# sort the two files and compare

	set tmp_config_file "[set ppp_config_file].tmp"
}

proc manage_accounts { } {

		global accounts account_list active_account
		# create win
		# add r/l frames
		# add text & scroll on left
		# add buttons on right
		# add account names to scroll text
		# map buttons to commands
		# create account window w/entry widgets,
		# label/entry for each acct field


   toplevel .account_manager_win
   wm title .account_manager_win "Account Manager"

   # Two frames, one for a scrolling list of accounts, the other for the buttons

   frame .account_manager_win.account_frame
   pack .account_manager_win.account_frame -side left -padx 1m -pady 1m

   listbox .account_manager_win.account_list -yscrollcommand \
      ".account_manager_win.scroll_bar set"
   .account_manager_win.account_list configure -height 10

   scrollbar .account_manager_win.scroll_bar -command \
      ".account_manager_win.account_list yview" -relief sunken
   .account_manager_win.scroll_bar set 5 5 0 4

   pack .account_manager_win.scroll_bar -in .account_manager_win.account_frame \
      -side left -fill y
   pack .account_manager_win.account_list \
      -in .account_manager_win.account_frame -side left 

   bind .account_manager_win.account_list <ButtonRelease-1> {
      set selected_account [selection get]
			puts "selected_account = $selected_account"
   }

   bind .account_manager_win.account_list <Double-ButtonPress-1> {
      set active_account $selected_account
			set_account $active_account
      #.account_frame.account_button configure -text $active_account
      destroy .account_manager_win
   }

   foreach account [set account_list] {
      .account_manager_win.account_list insert end "$account"
   }

   frame .account_manager_win.button_frame
   pack .account_manager_win.button_frame -padx 1m -pady 1m

   button .account_manager_win.select_button -text "Make Active" \
      -command {
				 puts "selected_account = $selected_account"
         set active_account $selected_account
         #.account_frame.account_button configure -text $active_account
				 # check if or not - if not, enable password
				 set_account $active_account
         #destroy .account_manager_win
      }
   button .account_manager_win.new_button -text New \
      -command {puts "Create New Account"}
   button .account_manager_win.edit_button -text Edit \
      -command {puts "Edit Account"}
   button .account_manager_win.delete_button -text Delete \
      -command {puts "Delete Account"}
   button .account_manager_win.close_button -text Close \
      -command {destroy .account_manager_win}
   pack .account_manager_win.select_button .account_manager_win.new_button \
      .account_manager_win.edit_button .account_manager_win.delete_button \
      .account_manager_win.close_button -in .account_manager_win.button_frame \
      -ipadx 2 -ipady 2 -padx 2 -pady 2 -fill x
}

proc blink_single {bulb } {

	global connection_state
	global incr_value
	global bulblist
	global on_color
	global off_color
	global bulb_colors 
	global after_intervals
	global after_interval
	global bulbs

		set after_interval [RandomRange 500 ] 


		if { [lsearch $bulb_colors $bulbs($bulb,color)] == [expr [llength $bulb_colors] - 1] } {
			set bulbs($bulb,color) [lindex $bulb_colors 0]
		} else {
			set bulbs($bulb,color) [lindex $bulb_colors [expr [lsearch $bulb_colors $bulbs($bulb,color)]  + 1]]
		}

		if { $after_interval > 250 } {
			.cframe.can itemconfigure $bulb -fill $bulbs($bulb,color) 
		}

		if { $connection_state != "connecting" } {
			.cframe.can itemconfigure all -fill black 
		} else {
			after $after_interval blink_single $bulb
		}
	

}

proc init_blinking_bulbs { } {

	global connection_state
	global incr_value
	global bulblist
	global bulbs
	global on_color
	global off_color
	global bulb_colors 
	global after_intervals
	global after_interval

	# set different intervals

	foreach bulb $bulblist {

		#puts "bulb $bulb"
		set after_interval [RandomRange 1000] 

		if { [lsearch $bulb_colors $bulbs($bulb,color)] == [expr [llength $bulb_colors] - 1] } {
			#puts "bulbs($bulb,color) = $bulbs($bulb,color)"
			set bulbs($bulb,color) [lindex $bulb_colors 0]
		} else {
			set bulbs($bulb,color) [lindex $bulb_colors [expr [lsearch $bulb_colors $on_color]  + 1]]
		}

			if { $bulb != "bulb0" && $bulb != "bulb3" && $bulb != "bulb10"  } {	
				#puts "init_blinking: .cframe.can itemconfigure $bulb -fill $bulbs($bulb,color)" 
				.cframe.can itemconfigure $bulb -fill $bulbs($bulb,color) 
				#after $after_interval blink_single $bulb
				blink_single $bulb
			} else {
				#puts "Constant: .cframe.can itemconfigure $bulb -fill green" 
				if { $bulb == "bulb0" || $bulb == "bulb3" } {
					.cframe.can itemconfigure $bulb -fill green 
				} else {
					.cframe.can itemconfigure $bulb -fill yellow 
				}
			}
	}
}

proc blink_bulbs {widget bulb_index direction} {


	global connection_state
	global incr_value
	global bulblist
	global on_color
	global off_color
	global bulb_colors 
	global after_intervals
	global after_interval

	# set different intervals

	set current_index $bulb_index 
	#puts "current_index = $current_index"
	set list_len [llength $bulblist]
	#puts "list_len = $list_len"

	set color [$widget itemcget [lindex $bulblist $current_index] -fill]

	if { $connection_state == "connecting" } {

		if { $current_index == [expr $list_len - 1] && $after_interval > 100 } {
			#puts "index = $current_index, set direction to left"
			set direction left 
		} elseif { $current_index == 0 } {
			#puts "index = $current_index, set direction to right"
			set direction right 
		}

		if { $direction == "left" } {
			set incr_value -1
			if { $current_index != [expr [llength $bulblist] - 1] } {
				#puts "current_index == $current_index"
				#puts "$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $off_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $off_color 
			} else {
				#puts "current_index == $current_index"
				#puts "$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $off_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $off_color 
			}
		} else {
			set incr_value 1
			if { $current_index != 0 } {
				#puts "current_index == $current_index"
				#puts "$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $off_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $off_color 
			} else {
				#puts "current_index == $current_index"
				#puts "$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $off_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $off_color 
			}
		}

		#puts "direction = $direction"

		#puts "$widget itemconfigure [lindex $bulblist $current_index] -fill $on_color" 
		$widget itemconfigure [lindex $bulblist $current_index] -fill $on_color 

		#puts "after blink_bulbs $widget [expr $current_index + $incr_value] $direction"

		if { [lsearch $bulb_colors $on_color] == [expr [llength $bulb_colors] - 1] } {
			set on_color [lindex $bulb_colors 0]
		} else {
			set on_color [lindex $bulb_colors [expr [lsearch $bulb_colors $on_color]  + 1]]
		}
		if { [lsearch $bulb_colors $off_color] == [expr [llength $bulb_colors] - 1] } {
			set off_color [lindex $bulb_colors 0]
		} else {
			set off_color [lindex $bulb_colors [expr [lsearch $bulb_colors $off_color]  + 1]]
		}

		if { [lsearch $after_intervals $after_interval] == [expr [llength $after_intervals] - 1] } {
			set after_interval [lindex $after_intervals 0] 
		} else {
			set after_interval [lindex $after_intervals [expr [lsearch $after_intervals $after_interval] + 1]]
		}
		after $after_interval blink_bulbs $widget [expr $current_index + $incr_value] $direction
	} else {
		$widget itemconfigure all -fill green 
	}

}

#proc blink_bulbs {widget} {
#
#	global connection_state
#
#	set color [$widget itemcget all -fill]
#	if { $color == "green" } { 
#		$widget itemconfigure all -fill yellow 
#	} else {
#		 $widget itemconfigure all -fill green 
#	}
#
#	if { $connection_state == "connecting" } {
#		after 1000 blink_bulbs $widget
#	} else {
#		$widget itemconfigure all -fill gray 
#	}
#
#}

proc edit_prefs { } {

	global ppp_settings
	global modem_port
	global flow_control

	puts "Modem port = $ppp_settings(modem_port)"

	if { [winfo exists .prefs] } { 
		 catch { wm deiconify .prefs }	
		 catch { wm raise .prefs }
	} else { 
		toplevel .prefs
		#wm geometry .prefs 500x200

		frame .prefs.pref_frame


			## Menubutton items ##

			foreach ppp_setting { modem_port flow_control } {

				set button_descr "[lindex [split $ppp_setting '_'] 0] [lindex [split $ppp_setting '_'] 1]"
				#set ppp_settings(modem_port) /dev/term/b
				frame .prefs.pref_frame.[set ppp_setting]_frame

				if { [info exists ppp_settings($ppp_setting)] == 1 } {
					puts "$ppp_setting = $ppp_settings($ppp_setting)"
					set [set ppp_setting]_button_text $ppp_settings($ppp_setting)
				} else {
					puts "$ppp_setting = $ppp_settings($ppp_setting)"
					set [set ppp_setting]_button_text "Select $button_descr" 
				}
				menubutton .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting] \
				-text [set [set ppp_setting]_button_text] \
				-menu .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting].menu -relief raised 

				pack .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting] -side right 
				label .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_label -text $button_descr
				pack .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_label -side right
				#.prefs.pref_frame.[set ppp_setting]_frame.modem_port configure -anchor w	


				pack .prefs.pref_frame.[set ppp_setting]_frame -fill x -expand 1
				eval { set [set ppp_setting]_menu \
				[menu .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting].menu -tearoff 0] }

				if { $ppp_setting == "modem_port" } {
					foreach modem_port [exec ls /dev/term] {
							set modem_port "/dev/term/[set modem_port]"
							puts "[set ppp_setting]_menu add command -label $modem_port -command"
							puts "ppp_settings: [array names ppp_settings]"

							eval { [set [set ppp_setting]_menu] add radio -label $modem_port -variable modem_port \
											-value $modem_port -command {
												.prefs.pref_frame.modem_port_frame.modem_port configure -text $modem_port
											}
							}
					}
				} elseif { $ppp_setting == "flow_control" } {

					foreach flow_control { hardware software } {
							puts "[set ppp_setting]_menu add command -label $flow_control -command"
							puts "ppps: [array names ppps]"

							eval { [set [set ppp_setting]_menu] add radio -label $flow_control -variable \
											flow_control  -value $flow_control -command {
												.prefs.pref_frame.flow_control_frame.flow_control \
												configure -text $flow_control
											}
							}
					}
			}
		}
			


			#### Entry items ###

			set last_width 0 
			foreach ppp_setting { port_speed init_string connect_string ppp_options } {
				puts "ppp_setting $ppp_setting"
				set entry_width [string length $ppp_settings($ppp_setting)]
				if { $entry_width < 20 } { set entry_width 25 }
				if { $entry_width > $last_width } { set last_width $entry_width }
			}
				if { $entry_width < $last_width } { set entry_width [expr $last_width + 5] }
				.prefs.pref_frame.modem_port_frame.modem_port configure -width $entry_width
				.prefs.pref_frame.flow_control_frame.flow_control configure -width $entry_width
			

			foreach ppp_setting { port_speed init_string connect_string ppp_options } {

				frame .prefs.pref_frame.[set ppp_setting]_frame
				label .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_label -text $ppp_setting 
				entry .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_entry -width $entry_width
				.prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_entry insert 0 $ppp_settings($ppp_setting)

				pack .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_entry -side right 
				pack .prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_label  -side right
				pack .prefs.pref_frame.[set ppp_setting]_frame -fill x -expand 1
			}



			#set ppp_settings(port_speed) 38400
			#set ppp_settings(flow_control) hardware

			#set ppp_settings(init_string) "atz" 
			#set ppp_settings(connect_string) ""
			#set ppp_settings(ppp_options) "" 

			pack .prefs.pref_frame

		frame .prefs.prefbuttons
		button .prefs.prefbuttons.prefs_save -text "Save" -command { 
			puts "Save Prefs" 
			foreach ppp_setting { port_speed init_string connect_string ppp_options } {
				set ppp_settings($ppp_setting) \
				[.prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_entry get]
				puts "saved ppp_setting $ppp_setting as \
				[.prefs.pref_frame.[set ppp_setting]_frame.[set ppp_setting]_entry get]"
			}
			foreach ppp_setting { modem_port flow_control } {
				set ppp_settings($ppp_setting) [set [set ppp_setting]] 
				puts "saved ppp_setting $ppp_setting as $ppp_settings($ppp_setting)" 
			}

			## write_global #
		}
		button .prefs.prefbuttons.prefs_close -text "Close" -command { destroy .prefs }
		pack .prefs.prefbuttons.prefs_save -side left
		pack .prefs.prefbuttons.prefs_close -side right
		pack .prefs.prefbuttons -side bottom
	}
}

proc log_message { message } {

	catch { [.log_win.log_text insert end $message] }
	catch [.log_win.log_text yview end]

}

proc view_log { } {
	catch { [wm deiconify .log_win] }
}

proc build_log_win { } {

	global accounts
	global active_account


	toplevel .log_win 
	wm title .log_win "PPP Log"
	wm withdraw .log_win

	frame .log_win.log_frame -relief flat
	text .log_win.log_text -relief sunken -borderwidth 2 \
	-yscrollcommand { .log_win.scroll_y set} \
	-height 20 -width 65 -setgrid true
	scrollbar .log_win.scroll_y -command ".log_win.log_text yview"
	pack .log_win.log_text -in .log_win.log_frame -side left -pady 1m -fill both
	pack .log_win.scroll_y -in .log_win.log_frame -side right -fill y

	frame .log_win.button_frame -relief flat
	button .log_win.close_button -text "Close" -command {\
		wm withdraw .log_win
	}

	pack .log_win.close_button -side bottom -in .log_win.button_frame \
	-ipadx 2 -padx 2

	pack .log_win.log_frame .log_win.button_frame -side top



}

proc add_accounts { } {

	global menubar_widget
	global acct_widget
	global color_array
	# list
	global account_list
	# array (account_name,key)
	global accounts

	#set color_array(AGNS) green
	#set color_array(ModemPool) blue
	#set color_array(SWAN) orange

	foreach account $account_list {
		add_account_menu $account
		#set color_array($account) yellow 
	}
}

proc set_account {value } {

	# display active account 

	global menubar_widget
	global active_account
	global color_array
	global accounts

	#$menubar_widget entryconfigure 3 -label $value
	.acct_label configure -text "Active Account: $active_account"
	# display active info for account	
	#.color configure -bg $color_array($active_account) 
	.namef.name_r configure -text "$active_account"
	#.uidf.uid_r configure -text "$accounts($active_account,uid)"
	.uidf.uid_r delete 0 end 
	.uidf.uid_r insert 0 "$accounts($active_account,uid)"
	.numberf.number_r configure -text "$accounts($active_account,number)"
	.authtypef.authtype_r configure -text "$accounts($active_account,authtype)"
	if { [info exists active_account] } {
		.connect configure -state normal
	} else {
		.connect configure -state normal
	}
}

proc delete_menu_acct { account_name } {

	global accounts
	# delete account from Menu


	# get index of $account_name
	#.menubar.mAccounts delete $accounts($account_name,menu_index)
	

}
proc set_menu {value } {
	global menubar_widget
	global active_account
	$menubar_widget entryconfigure 3 -label $value
}

proc add_account_menu {name} {

	global menubar_widget
	global acct_widget
	global active_account
	global accounts

	$acct_widget add radio  -variable active_account \
	-value $name -label $name -command { set_account $active_account }
	
	# save menu position

}

############################################################


# 
# account  ModemPool
# ppp_uid  
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
#pppopts
#init_string
#connect_string
#port_speed
#flow_control
#modem_port

#Account format - single file

# load global settings
proc load_global { } {
	global ppp_dir
	global ppp_config_file
	global ppp_settings

	set ppp_settings(init_string) "atz" 
	set ppp_settings(connect_string) ""
	set ppp_settings(port_speed) 38400
	set ppp_settings(flow_control) hardware
	set ppp_settings(modem_port) /dev/term/b
	set ppp_settings(ppp_options) "" 

	set ppp_config_file "$ppp_dir/ppp_settings"

	if { [file exists  $ppp_config_file] != 1 } {
		puts "Creating $ppp_config_file"
		set global_fd [open $ppp_config_file w]
		# put in defaults
		foreach key [array names ppp_settings] {
			puts $global_fd "$key\t$ppp_settings($key)"
		}
		close $global_fd
	} else {
		puts "Reading $ppp_config_file"
		set ppp_fd [open $ppp_config_file r]
		while { [gets $ppp_fd line] != -1 } {
			set split_line [split $line "\t"]
			set ppp_settings([lindex $split_line 0]) [lindex $split_line 1]
			puts "set ppp_settings([lindex $split_line 0]) [lindex $split_line 1]"
		}
	}
	#pppopts
	# init_string
	# connect_string
	# port_speed
	# flow_control
	# modem_port

}

proc load_accts { } {

	global env
	global ppp_dir
	# list
	global account_list
	# array (account_name,key)
	global accounts
	# account file names
	global account_file
	global account_keys

	set account_name ""

	if { [file exists $account_file] } {

		set account_fd [open $account_file r]

				# parse into acct_array
				for { set i 0 } { [gets $account_fd line] != -1 } {incr i} {

					if { [string length $line] < 1 } { continue }
					set field [split $line "\t"]
					set key [lindex $field 0]
					string trim $key
					puts "Key=$key"
					set value [lindex $field 1]
					puts "Value=$value"

					# check key
					if { [lsearch $account_keys $key] == -1 } {
						puts "Invalid key $key found in account file $acct"
						continue
					}

					# make sure account name is same as file prefix
					if { $key == "name" } {
						# New account
						puts "Account $value"
						set account_name $value
						lappend account_list $value
					}
							puts "Adding key '$key' value '$value' to accounts"
							set accounts($account_name,$key) $value
				}

				close $account_fd
	} 
			# done
			puts "Loaded accounts"

}

proc init { } {

	global ppp_settings
	global env
	global ppp_dir
	set ppp_dir "$env(HOME)/.ppptool" 
	global ppp_config_file
	set ppp_config_file "$ppp_dir/ppp_settings"
	# list
	global active_account
	global account_list
	set account_list {}

	# array (account_name,key)
	global accounts
	
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
	}

	global account_file
	set account_file "$ppp_dir/accounts"
	RandomInit [pid]

	if { [string first "sun" [exec arch]] != -1 } { 
		option add *font {palatino 12 bold} 
	}
	load_global
	load_accts
	build_log_win
	build_menus

}

init


#proc mainwin { } {
#proc RandomInit { seed } {
#proc Random {} {
#proc RandomRange { range } {
#proc build_menus { } {
#proc blink_single {bulb } {
#proc init_blinking_bulbs { } {
#proc blink_bulbs {widget bulb_index direction} {
##proc blink_bulbs {widget} {
#proc edit_prefs { } {
#proc log_message { message } {
#proc view_log { } {
#proc build_log_win { } {
#proc add_accounts { } {
#proc set_account {value } {
#proc delete_menu_acct { account_name } {
#proc set_menu {value } {
#proc add_account_menu {name} {
#proc load_global { } {
#proc load_accts { } {
#proc init { } {
