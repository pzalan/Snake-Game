extends Node

@export var snake_scene : PackedScene 

# game variables
var score : int
var game_started : bool = false

#grid variables
var cells : int = 20
var cell_size : int = 50

#food variables
var food_pos : Vector2
var regen_food : bool = true

#snake variables
var old_data : Array #prev grid cords
var snake_data : Array #current grid cords
var snake : Array

#movement variables 
var start_pos =Vector2(9,9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2 # current direction
var can_move : bool # can use to stop the snake


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	pass # Replace with function body.
	
func new_game():
	get_tree().paused = false #will unpaused the game 
	get_tree().call_group("Segments", "queue_free") #will get rid of the snake from previous game 
	$"Game Over Menu".hide() #will hide the game over menu 
	score = 0 #sets the score to zero 
	$CanvasLayer.get_node("ScoreLabel").text = "SCORE: " + str(score) #updates the text of score label 
	move_direction = up #set direction to up and move to true
	can_move = true
	generate_snake()
	move_food()
	
func generate_snake():
	old_data.clear() # will first clear data in the three arrays
	snake_data.clear()
	snake.clear()
	
	#starting with the start_pos, create tail segments vertically down
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos):
	snake_data.append(pos) # stores the grid pos in the array 
	var SnakeSegment = snake_scene.instantiate() #creates a segment scene and positions it on screen 
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size) # offset by 1 cell_size to leave room at the top for score panel
	add_child(SnakeSegment)
	snake.append(SnakeSegment) #keep track of it
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	pass

func move_snake():
	if can_move:
		# update movement from key presses
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()

# this will start the game if not already started
func start_game():
	game_started = true 
	$MoveTimer.start()


func _on_move_timer_timeout():
	#allow snake movement
	can_move = true
	#use the snake's previous position to move the segments
	old_data  = [] + snake_data #saves the current data into the old for reference 
	snake_data[0] += move_direction #puts the new position
	for i in range(len(snake_data)):
		#move all the segments along by one
		if i > 0:
			snake_data[i] = old_data[i-1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	pass

#check for position of the snake's head and if its outside of grid, will end game
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()

#iterates through each body segment and checks if cords are the same as head, will end game if so 
func check_self_eaten():
	for i in range(1, len(snake_data)): 
		if snake_data[0] == snake_data[1]:
			end_game()

func check_food_eaten():
	#if snake eats the food, add a segment and move the food
	if snake_data[0] == food_pos: #checks if head cords is same as food cords
		score += 1 
		$CanvasLayer.get_node("ScoreLabel").text = "SCORE: " + str(score) # increases the score
		add_segment(old_data[-1])
		move_food()
	pass
	
	
# makes sure that the food doesn't overlap with the snake
func move_food():
	while regen_food:
		regen_food = false 
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size) # when we pick a position that is free, then assign to food node
	regen_food = true 
	
func end_game():
	$"Game Over Menu".show()
	$MoveTimer.stop()
	game_started = false 
	get_tree().paused = true
	pass


func _on_game_over_menu_restart():
	new_game()
	pass 
