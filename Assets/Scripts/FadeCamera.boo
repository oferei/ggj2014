import UnityEngine

class FadeCamera (MonoBehaviour): 

	_texture as Texture2D
	_style as GUIStyle

	enum State:
		Idle
		FadeIn
		FadeOut

	_state as State

	_fadeStartTime as single
	_color as Color
	_duration as single

	def Awake():
		_texture = Texture2D(1, 1)
		#_texture.SetPixel(0, 0, Color.red)
		#_texture.Apply()
		_style = GUIStyle()
		_style.normal.background = _texture

	def fadeOut(color as Color, duration as single):
		_state = State.FadeOut
		_fadeStartTime = Time.time
		_color = color
		_duration = duration

	def fadeIn(color as Color, duration as single):
		_state = State.FadeIn
		_fadeStartTime = Time.time
		_color = color
		_duration = duration

	def OnGUI():
		if _state in (State.FadeOut, State.FadeIn):
			t = (Time.time - _fadeStartTime) / _duration
			if _state == State.FadeIn:
				t = 1 - t

			curColor = Color.Lerp(Color(0, 0, 0, 0), _color, t)
			#if t > 0.99:
			#	_state = State.Idle
			#	curColor = _color
			_texture.SetPixel(0, 0, curColor)
			_texture.Apply()
			GUI.Box(Rect(0, 0, Screen.width, Screen.height), GUIContent.none, _style)
			#GUI.Box(position, GUIContent.none, _style)
