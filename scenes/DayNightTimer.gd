extends Timer

enum Cycle {
	DAY,
	NIGHT
}

var cycle

func _ready():
	cycle = Cycle.DAY
	connect("timeout", self, "_end_of_cycle")
	
func process(delta):
	$ProgressBar.value = time_left / 120 * 100

func _end_of_cycle():
	if cycle == Cycle.DAY:
		cycle = Cycle.NIGHT
	else:
		cycle = Cycle.DAY