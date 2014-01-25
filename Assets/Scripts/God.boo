import UnityEngine

class God():

	static Inst as God:
	""" Calls upon God """
		get:
			God() unless _instance
			return _instance
	static _instance as God

	Hermes:
	""" The messenger """
		get:
			return _hermes
	_hermes as Messenger

	Ground:
	""" The ground """
		get:
			return _ground
		set:
			assert not _ground
			_ground = value
	_ground as Transform

	Player:
	""" The Player's BADAS """
		get:
			return _player
		set:
			assert not _player
			_player = value
	_player as Transform

	private def constructor ():
	""" Wakes up God """
	
		Debug.Log("Beware, I live!")
		_instance = self
		_hermes = Messenger()
