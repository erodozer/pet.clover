extends TextureRect

const fade_in: AnimatedTexture = preload("./in_anim.tres")
const fade_out: AnimatedTexture = preload("./out_anim.tres")

func transition(fn: FuncRef):
	texture = fade_out
	texture.current_frame = 0
	
	# wait for animation
	while texture.current_frame < texture.frames:
		yield(get_tree(), "idle_frame")
	
	var r = fn.call_func()
	
	if r is GDScriptFunctionState:
		yield(r, "completed")
		
	texture = fade_in
	texture.current_frame = 0
	
	# wait for animation
	while texture.current_frame < texture.frames:
		yield(get_tree(), "idle_frame")
	
