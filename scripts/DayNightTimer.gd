extends Timer

enum Cycle {
	DAY,
	NIGHT
}

var cycle

func _ready():
	cycle = Cycle.DAY
	connect("timeout", self, "_end_of_cycle")
	
func _process(delta):
	get_parent().dn_prog_bar.value = (wait_time - time_left) / wait_time * 100

func _end_of_cycle():
	if cycle == Cycle.DAY:
		cycle = Cycle.NIGHT
		get_parent().dn_label.text = 'Nighttime'
	else:
		cycle = Cycle.DAY
		get_parent().dn_label.text = 'Daytime'
