import UnityEngine

class TempleCenter (MonoBehaviour): 

	public flipClip as AudioClip
	public trippinClip as AudioClip

	def OnTriggerEnter(otherCollider as Collider):
		otherCollider.SendMessage("OnTouchedAltar")

		trigger = GetComponent[of SphereCollider]()
		trigger.enabled = false

		audio.Stop()

		audio.clip = flipClip
		audio.loop = false
		audio.Play()

		Invoke("playTripping", 10)

	def playTripping():
		audio.clip = trippinClip
		audio.loop = true
		audio.Play()
