import UnityEngine

class Perspective (MonoBehaviour): 

	public lookTarget as Transform

	def OnTouchedAltar ():
		#Invoke("fadeOut", 1)
		fadeOut()
		Invoke("fadeIn", 7)

	def fadeOut():
		Camera.main.GetComponent[of FadeCamera]().fadeOut(Color.white, 5)

	def fadeIn():
		Camera.main.orthographic = true
		Camera.main.transform.LookAt(lookTarget)
		Camera.main.transform.eulerAngles.x = 0;
		Camera.main.transform.eulerAngles.z = 0;
		Camera.main.GetComponent[of FadeCamera]().fadeIn(Color.white, 4.0)
