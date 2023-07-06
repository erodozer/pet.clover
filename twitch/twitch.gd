# simple integrations with twitch chat when running in HTML5 mode
extends Window

@onready var tmi = get_parent() as Tmi

func _ready():
	if not FileAccess.file_exists("user://user.conf"):
		return # no save yet
	
	var conf = JSON.parse_string(FileAccess.get_file_as_string("user://user.conf"))
	if conf == null:
		return # could not parse config
		
	%TwitchChannel.text = conf.get("twitch", "")
	var cred = TwitchCredentials.new()
	cred.channel = %TwitchChannel.text
	
	tmi.credentials = cred
	tmi.connection_status_changed.connect(_on_twitch_connection_status_changed)
	
	tmi.start()

func _on_connect_button_pressed():
	var cred = TwitchCredentials.new()
	cred.channel = %TwitchChannel.text
	
	tmi.credentials = cred
	
	tmi.start()
	
	var conf = JSON.stringify({
		"twitch": cred.channel
	})
	var file = FileAccess.open("user://user.conf", FileAccess.WRITE_READ)
	file.store_string(conf)
	file.close()
	
func _on_twitch_connection_status_changed(status):
	var connected = status != Tmi.ConnectionStatus.NOT_CONNECTED
	
	%ConnectionStatus.text = "Connected" if connected else "Disconnected"
	%ConnectionStatus.modulate = Color.LIGHT_GREEN if connected else Color.WHITE

func _process(_delta):
	if Input.is_key_pressed(KEY_F1):
		visible = true

func _on_close_requested():
	visible = false

func _on_disconnect_button_pressed():
	tmi.credentials = TwitchCredentials.new()
	tmi.start()
