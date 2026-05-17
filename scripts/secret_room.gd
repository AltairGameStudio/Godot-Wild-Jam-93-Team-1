extends Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var anim_sprite2 = $AnimatedSprite2D2
@onready var anim_sprite3 = $AnimatedSprite2D3
@onready var anim_sprite4 = $AnimatedSprite2D4
@onready var anim_sprite5 = $AnimatedSprite2D5
@onready var anim_sprite6 = $AnimatedSprite2D6
@onready var anim_sprite7 = $AnimatedSprite2D7

@onready var shooting_stars = [anim_sprite, anim_sprite2, anim_sprite3, anim_sprite4, anim_sprite5, anim_sprite6, anim_sprite7]

func _ready():
	for star in shooting_stars:
		star.play("default")
