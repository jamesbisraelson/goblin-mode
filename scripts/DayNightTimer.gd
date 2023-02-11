extends Timer

var cycle

signal end_of_cycle

const Cycle = preload('res://scripts/Enums.gd').Cycle

func _ready():
	cycle = Cycle.DAY
	connect("timeout", self, "_end_of_cycle")
	connect("end_of_cycle", get_parent(), "_end_of_cycle")
	
func _process(delta):
	get_parent().dn_prog_bar.value = (wait_time - time_left) / wait_time * 100

func _end_of_cycle():
	emit_signal("end_of_cycle", cycle)	
	if cycle == Cycle.DAY:
		cycle = Cycle.NIGHT
		get_parent().dn_label.text = 'Nighttime'
	else:
		cycle = Cycle.DAY
		get_parent().dn_label.text = 'Daytime'
