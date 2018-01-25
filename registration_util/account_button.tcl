#
# Example 27-6
# A menu sampler.

#

proc set_menu {widget value } {

	$widget configure -text $value
}

set current_acct ""

menubutton .mb -text Sampler -menu .mb.menu -relief raised
pack .mb -padx 10 -pady 10

set m [menu .mb.menu -tearoff 0]

#$m add cascade -label Accounts -menu $m.sub1

#set m2 [menu $m.sub1 -tearoff 0]

$m add radio -label AGNS -variable current_acct \
-value ATGS -command { set_menu .mb $current_acct }

$m add radio -label Modempool -variable current_acct \
-value Modempool -command { set_menu .mb $current_acct }

$m add radio -label SWAN -variable current_acct \
-value SWAN -command { set_menu .mb $current_acct }


