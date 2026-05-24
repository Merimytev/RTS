extends Label

var travel = Vector2(0, -60)
var duration = 1
var spread = PI/2



func show_value(value):
	var tween = create_tween()
	text = "+ " + str(value)
	pivot_offset = size / 4
	
	var movement = travel.rotated(randf_range(-spread/2, spread/2))
	
	tween.tween_property(self, "position", position + movement, duration)
	
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
		
	tween.play()
	tween.tween_callback(self.queue_free)
