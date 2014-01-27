class MessageSkin (Message): 

	skin:
		get:
			return _skin
	_skin as Skin
 
	def constructor(skin):
 
		_skin = skin
 
		# send the message
		super()
