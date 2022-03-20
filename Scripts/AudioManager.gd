extends Node

const NUM_PLAYERS : int = 8
var bus : String  = "master"

var available : Array = []
var queue : Array = []


func _ready():
	for i in NUM_PLAYERS:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus

func _process(delta : float) -> void:
	print("Available Audio Streams: ", len(available))
	if not queue.empty() and not available.empty():
		print("Audio Queue: ", queue)
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

func play(sound_path : String) -> void:
	queue.append(sound_path)

######################
# SIGNAL CONNECTIONS #
######################

func _on_stream_finished(stream : AudioStreamPlayer) -> void:
	available.append(stream)
