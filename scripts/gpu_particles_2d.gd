extends GPUParticles2D

var particles_material: ParticleProcessMaterial

func _ready():
	particles_material = ParticleProcessMaterial.new()
	
	print(particles_material.angle_max)
	print(particles_material.particle_flag_rotate_y)
