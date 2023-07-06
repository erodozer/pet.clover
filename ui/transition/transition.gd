extends TextureRect

const fade_in: AnimatedTexture = preload("./in_anim.tres")
const fade_out: AnimatedTexture = preload("./out_anim.tres")

func transition(fn: Callable):
	texture = fade_out
	texture.current_frame = 0
	
	# wait for animation
	while texture.current_frame < texture.frames:
		await get_tree().process_frame
	
	await fn.call()
		
	texture = fade_in
	texture.current_frame = 0
	
	# wait for animation
	while texture.current_frame < texture.frames:
		await get_tree().process_frame
	
