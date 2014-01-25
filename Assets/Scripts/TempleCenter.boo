import UnityEngine

class TempleCenter (MonoBehaviour): 

	def OnTriggerEnter(collider as Collider):
		Debug.Log("message as object")
		collider.SendMessage("OnTouchedAltar")
