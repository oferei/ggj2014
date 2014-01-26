import UnityEngine

class Perspective (MonoBehaviour): 

	public lookTarget as Transform

	def OnTouchedAltar ():
		Camera.main.GetComponent[of FadeCamera]().fadeOut(Color.white, 1.2)
		Invoke("fadeIn", 3)

	def fadeIn():
		Camera.main.orthographic = true
		Camera.main.transform.LookAt(lookTarget)
		Camera.main.transform.eulerAngles.x = 0;
		Camera.main.transform.eulerAngles.z = 0;
		Camera.main.GetComponent[of FadeCamera]().fadeIn(Color.white, 4.0)
