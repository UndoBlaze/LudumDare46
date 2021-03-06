extends Node2D
class_name UnitManager

signal set_path(unit)
signal wave_over()
signal unit_killed(value)

onready var ySort : YSort = $Units
onready var wave_controller : WaveController = $WaveController
onready var audioCoin : AudioStreamPlayer = $AudioCoin
onready var audioDeath : AudioStreamPlayer = $AudioDeath

export(Array, Texture) var unit_textures
var game_manager : GameManager
var unit_prefab = load("res://prefabs/Unit.tscn")
var unit_count : int = 0

func _ready():
	game_manager = get_node("/root/GameManager")
	wave_controller.connect("spawn", self, "_on_spawn")
	
func next_wave():
	wave_controller.next_wave()
	
func update_paths():
	for unit in ySort.get_children():
		emit_signal("set_path", unit)

func get_spawners():
	return wave_controller.get_spawn_points()

func _on_spawn(value : int, positon : Vector2):
	var unit : Unit = unit_prefab.instance()
	ySort.add_child(unit)
	unit.set_Unit(value, unit_textures[randi() % unit_textures.size()])
	unit.position = positon
	emit_signal("set_path", unit)
	unit.connect("death", self, "_on_death")
	unit_count += 1
	
func _on_death(value):
	unit_count -= 1
	game_manager.set_coins(game_manager.get_coins() + value)
	emit_signal("unit_killed", value)
	if !audioCoin.playing || audioCoin.get_playback_position() > 0.05:
		audioCoin.pitch_scale = rand_range(0.8, 1.2)
		audioCoin.play()
	if !audioDeath.playing || audioDeath.get_playback_position() > 0.05:
		audioDeath.pitch_scale = rand_range(0.8, 1.2)
		audioDeath.play()
	if unit_count == 0 and wave_controller.is_wave_over():
		emit_signal("wave_over")
