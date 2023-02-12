extends Timer

var day_num: int

signal end_of_day

func _ready():
	day_num = 1
	connect("timeout", self, "_end_of_day")
	connect("end_of_day", get_parent(), "_end_of_day")
	
func _process(delta):
	get_parent().dn_prog_bar.value = (wait_time - time_left) / wait_time * 100

func _end_of_day():
	emit_signal("end_of_day")
	day_num += 1
	get_parent().dn_label.text = 'day ' + str(day_num)
