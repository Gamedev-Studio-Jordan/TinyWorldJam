class_name Line3D extends MeshInstance3D

@export var m_pntStart : Vector3 = Vector3.ZERO : get=get_start,set=set_start

@export var m_pntEnd : Vector3 = Vector3.ZERO : get=get_end,set=set_end

var m_color : Color = Color.GREEN

var m_material : ORMMaterial3D = ORMMaterial3D.new()

func _ready():
	mesh = ImmediateMesh.new()
	m_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
func _process(_delta):
	draw()

func get_start():
	return m_pntStart

func get_end():
	return m_pntEnd
	
func set_start(a : Vector3):
	m_pntStart = a
	
func set_end(a : Vector3):
	m_pntEnd = a

func set_color(a):
	m_color = a
	m_material.albedo_color = m_color

func draw():
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, m_material)
	mesh.surface_add_vertex(m_pntStart)
	mesh.surface_add_vertex(m_pntEnd)
	mesh.surface_end()