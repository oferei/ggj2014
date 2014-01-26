import UnityEngine

class TempleCenter (MonoBehaviour): 

	public altClip as AudioClip

	def OnTriggerEnter(otherCollider as Collider):
		otherCollider.SendMessage("OnTouchedAltar")

		audio.Stop()
		audio.clip = altClip
		audio.PlayDelayed(5)

		trigger = GetComponent[of SphereCollider]()
		trigger.enabled = false


