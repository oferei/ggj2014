import UnityEngine

class TempleCenter (MonoBehaviour): 

	public altClip as AudioClip

	def OnTriggerEnter(collider as Collider):
		Debug.Log("message as object")
		collider.SendMessage("OnTouchedAltar")

		audio.Stop()
		audio.clip = altClip
		audio.PlayDelayed(5)

