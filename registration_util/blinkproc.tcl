proc blink_bulbs {widget} {

	global connection_state

	set color [$widget itemcget all -fill]
	if { $color == "green" } { 
		$widget itemconfigure all -fill yellow 
	} else {
		 $widget itemconfigure all -fill green 
	}

	if { $connection_state == "connecting" } {
		after 1000 blink_bulbs $widget
	} else {
		$widget itemconfigure all -fill gray 
	}

}
