proc bulb_init { } {

	global incr_value
	set incr_value 1
	global bulblist
	global registration_state
	set registration_state registering
	global trailing_color
	set trailing_color blue
	frame .cframe
	canvas .cframe.can -width 150 -height 20 

	set x1 5
	set y1 5
	set x2 15
	set y2 15

	foreach can_oval { 0 1 2 3 4 5 6 7 8 9 } {
		.cframe.can create oval $x1 $y1 $x2 $y2 -fill $trailing_color -width 2 -tag bulb[set can_oval]
		set bulbs("bulb[set can_oval]",color) blue
		puts "lappend bulblist bulb[set can_oval]"
		lappend bulblist "bulb[set can_oval]"
		incr x1 15
		set x2 [expr $x1 + 10]	
	}
	pack .cframe.can
	pack .cframe
}

proc blink_bulbs {widget bulb_index direction} {

	global registration_state
	global incr_value
	global bulblist
	global trailing_color

	set current_index $bulb_index 
	puts "current_index = $current_index"
	set list_len [llength $bulblist]
	puts "list_len = $list_len"

	set color [$widget itemcget [lindex $bulblist $current_index] -fill]

	set trailing_color blue

	if { $registration_state == "registering" } {

		if { $current_index == [expr $list_len - 1] } {
			puts "index = $current_index, set direction to left"
			set direction left 
		} elseif { $current_index == 0 } {
			puts "index = $current_index, set direction to right"
			set direction right 
		}

		if { $direction == "left" } {
			set incr_value -1
			if { $current_index != [expr [llength $bulblist] - 1] } {
				puts "current_index == $current_index"
				puts "$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $trailing_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $trailing_color 
			} else {
				puts "current_index == $current_index"
				puts "$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $trailing_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $trailing_color 
			}
		} else {
			set incr_value 1
			if { $current_index != 0 } {
				puts "current_index == $current_index"
				puts "$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $trailing_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index - 1]] -fill $trailing_color 
			} else {
				puts "current_index == $current_index"
				puts "$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $trailing_color" 
				$widget itemconfigure [lindex $bulblist [expr $current_index + 1]] -fill $trailing_color 
			}
		}

		puts "direction = $direction"

		puts "$widget itemconfigure [lindex $bulblist $current_index] -fill yellow" 
		$widget itemconfigure [lindex $bulblist $current_index] -fill yellow 


		puts "after 50 blink_bulbs $widget [expr $current_index + $incr_value] $direction"
		after 50 blink_bulbs $widget [expr $current_index + $incr_value] $direction
	} elseif { $registration_state == "registered" } {
		$widget itemconfigure all -fill green 
	} elseif { $registration_state == "failed" } {
		$widget itemconfigure all -fill red 
	}

}

bulb_init
blink_bulbs .cframe.can 0 right
