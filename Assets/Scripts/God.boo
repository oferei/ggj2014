#import UnityEngine

class God():
	
	static inst as God:
	""" Calls upon God """
		get:
			God() unless _instance
			return _instance
	static _instance as God
	
	hermes:
	""" The messenger """
		get:
			return _hermes
	_hermes as Messenger
	
	soundVolume:
	""" Master sound volume """
		get:
			return _soundVolume
		set:
			_soundVolume = value
	_soundVolume as single = 1
	
	private def constructor():
	""" Wakes up God """
	
		UnityEngine.Debug.Log("Beware, I live!")
		_instance = self
		_hermes = Messenger()
