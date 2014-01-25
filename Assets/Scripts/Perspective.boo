import UnityEngine

class Perspective (MonoBehaviour): 

	public lookTarget as GameObject

	def OnTouchedAltar ():
		Debug.Log("touched the altar")
		Camera.main.GetComponent[of FadeCamera]().fadeOut(Color.white, 1.2)
		Invoke("fadeIn", 5)

	def fadeIn():
		Camera.main.orthographic = true
		Camera.main.transform.LookAt(lookTarget.transform)
		Camera.main.transform.eulerAngles.x = 0;
		Camera.main.transform.eulerAngles.z = 0;
		Camera.main.GetComponent[of FadeCamera]().fadeIn(Color.white, 4.0)
