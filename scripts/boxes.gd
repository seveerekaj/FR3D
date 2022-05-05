extends GridMap

const FIRST_SURFACE = 0
const BOX_OFFSET = 0.5
const COLOR_RED = Color8(255,0,0)
const COLOR_GREEN = Color8(0,255,0)
const COLOR_BLUE = Color8(0,0,255)
const COLOR_ORANGE = Color8(255,174,0)
const COLOR_PURPLE = Color8(181,0,255)
const BOX_RED = "box_red"
const BOX_GREEN = "box_green"
const BOX_BLUE = "box_blue"
const BOX_ORANGE = "box_orange"
const BOX_PURPLE = "box_purple"
const BOX_BROWN = "box_brown"
const BOX_CHANGE_RED = "box_change_red"
const BOX_CHANGE_GREEN = "box_change_green"
const BOX_CHANGE_BLUE = "box_change_blue"
const BOX_CHANGE_ORANGE = "box_change_orange"
const BOX_CHANGE_PURPLE = "box_change_purple"

var box = preload("res://assets/box.tscn")
var brownBoxColor = preload("res://textures/WoodFloor035_1K_Color.jpg")
var brownBoxNormals = preload("res://textures/WoodFloor035_1K_NormalGL.jpg")
var changeRedColor = preload("res://textures/box_change_red.jpg")
var changeGreenColor = preload("res://textures/box_change_green.jpg")
var changeBlueColor = preload("res://textures/box_change_blue.jpg")
var changeOrangeColor = preload("res://textures/box_change_orange.jpg")
var changePurpleColor = preload("res://textures/box_change_purple.jpg")
var redMaterial = SpatialMaterial.new()
var greenMaterial = SpatialMaterial.new()
var blueMaterial = SpatialMaterial.new()
var orangeMaterial = SpatialMaterial.new()
var purpleMaterial = SpatialMaterial.new()
var brownMaterial = SpatialMaterial.new()
var changeRedMaterial = SpatialMaterial.new()
var changeGreenMaterial = SpatialMaterial.new()
var changeBlueMaterial = SpatialMaterial.new()
var changeOrangeMaterial = SpatialMaterial.new()
var changePurpleMaterial = SpatialMaterial.new()

# prepare the resources to be used in GridMap cell replacements
func initializeMaterials():
	blueMaterial.set_albedo(COLOR_BLUE)
	redMaterial.set_albedo(COLOR_RED)
	greenMaterial.set_albedo(COLOR_GREEN)
	orangeMaterial.set_albedo(COLOR_ORANGE)
	purpleMaterial.set_albedo(COLOR_PURPLE)
	
	brownMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, brownBoxColor)
	changeRedMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, changeRedColor)
	changeGreenMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, changeGreenColor)
	changeBlueMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, changeBlueColor)
	changeOrangeMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, changeOrangeColor)
	changePurpleMaterial.set_texture(SpatialMaterial.TEXTURE_ALBEDO, changePurpleColor)
	
	brownMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	changeRedMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	changeGreenMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	changeBlueMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	changeOrangeMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	changePurpleMaterial.set_texture(SpatialMaterial.TEXTURE_NORMAL, brownBoxNormals)
	
	blueMaterial.resource_name = BOX_BLUE
	redMaterial.resource_name = BOX_RED
	greenMaterial.resource_name = BOX_GREEN
	orangeMaterial.resource_name = BOX_ORANGE
	purpleMaterial.resource_name = BOX_PURPLE
	brownMaterial.resource_name = BOX_BROWN
	changeRedMaterial.resource_name = BOX_CHANGE_RED
	changeGreenMaterial.resource_name = BOX_CHANGE_GREEN
	changeBlueMaterial.resource_name = BOX_CHANGE_BLUE
	changeOrangeMaterial.resource_name = BOX_CHANGE_ORANGE
	changePurpleMaterial.resource_name = BOX_CHANGE_PURPLE

# iterate over all cells of GridMap and replace each with a SpatialMaterial object of
# the appropriate color/texture
func replaceCells():
	var meshLibrary = get_mesh_library()
	var cells = get_used_cells()
	
	for cell in cells:
		# create new instance of breakable box
		var new_box = box.instance()
		add_child(new_box)
		new_box.translate(Vector3(cell.x + BOX_OFFSET, cell.y + BOX_OFFSET, cell.z + BOX_OFFSET))
		
		# get resource name (indicates color) of cell in gridmap
		var mesh = meshLibrary.get_item_mesh(get_cell_item(cell.x, cell.y, cell.z))
		var color = mesh.surface_get_material(FIRST_SURFACE).resource_name
		
		# set new_box material (which includes color) based on gridmap cell color
		var new_box_mesh = new_box.get_node("MeshInstance")
		match color:
			BOX_BLUE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, blueMaterial)
			BOX_RED:
				new_box_mesh.set_surface_material(FIRST_SURFACE, redMaterial)
			BOX_GREEN:
				new_box_mesh.set_surface_material(FIRST_SURFACE, greenMaterial)
			BOX_ORANGE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, orangeMaterial)
			BOX_PURPLE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, purpleMaterial)
			BOX_BROWN:
				new_box_mesh.set_surface_material(FIRST_SURFACE, brownMaterial)
			BOX_CHANGE_RED:
				new_box_mesh.set_surface_material(FIRST_SURFACE, changeRedMaterial)
			BOX_CHANGE_GREEN:
				new_box_mesh.set_surface_material(FIRST_SURFACE, changeGreenMaterial)
			BOX_CHANGE_BLUE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, changeBlueMaterial)
			BOX_CHANGE_ORANGE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, changeOrangeMaterial)
			BOX_CHANGE_PURPLE:
				new_box_mesh.set_surface_material(FIRST_SURFACE, changePurpleMaterial)
			_:
				print("color not found: ", color, " - this cell in gridmap will be lost!")

# GridMap is great for setting up the scene, because you can paint the boxes to the screen
# wherever you want them. However, I found that GridMap handles collisions very poorly, so
# this script iterates over all cells of the GridMap at the beginning of the game and replaces
# them with SpatialMaterial objects which handle collisions nicely.
func _ready():	
	initializeMaterials()
	replaceCells()
	# after all cells have been replaced with breakable boxes, clear all cells of this gridmap
	clear()
