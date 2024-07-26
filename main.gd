extends Control

@onready var file_dialog: FileDialog = %FileDialog
@onready var height: TextEdit = %height
@onready var width: TextEdit = %width
@onready var image_dock: Control = %ImageDock
@onready var sprite_image: Sprite2D = %Image

var file:Image

func _ready() -> void:
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	file = Image.new()

func _on_file_dialog_file_selected(path: String) -> void:
	if(file.load(path) == OK):
		file_dialog.current_dir = path
		var img:Image = Image.load_from_file(path)
		if(img.get_size() > Vector2i(int(image_dock.size.x), int(image_dock.size.y))):
			img.resize(image_dock.size.x, image_dock.size.y, Image.INTERPOLATE_BILINEAR)
		sprite_image.texture = ImageTexture.create_from_image(img)

func _on_file_dialog_canceled() -> void:
	file_dialog.visible = false

func _on_file_dialog_dir_selected(dir: String) -> void:
	var slice_width = width.text.to_int()
	var slice_height = height.text.to_int()
	var index = 0
	var new_dir:DirAccess = DirAccess.open(dir)
	new_dir.make_dir("SingleImages")
	var img_dir:String = new_dir.get_current_dir() + "/SingleImages/"
	for i in range(0, file.get_height(), slice_height):
		for j in range(0, file.get_width(), slice_width):
			var new_img: Image = Image.new()
			new_img = Image.create(slice_width, slice_height, false, Image.FORMAT_RGBA8)
			new_img.blit_rect(file, Rect2(j, i, slice_width, slice_height), Vector2(0, 0))
			if(!is_image_empty(new_img)):
				new_img.save_png(img_dir + "slice_" + str(index) + ".png")
			index += 1
	OS.shell_open(img_dir)
	get_tree().quit()

func is_image_empty(image: Image) -> bool:
	if(image.get_width() == 0 or image.get_height() == 0):
		return true
	var first_color = image.get_pixel(0, 0)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y) != first_color:
				return false
	return true



func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_open_file_button_pressed() -> void:
	file_dialog.visible = true


func _on_convert_file_button_pressed() -> void:
	if((width.text.is_empty() && height.text.is_empty()) || !width.text.is_valid_int() || !height.text.is_valid_int()):
		return
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.visible = true
