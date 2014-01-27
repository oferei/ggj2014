import UnityEngine

class TempleCenter (MonoBehaviour): 

	public flipClip as AudioClip
	public trippinClip as AudioClip
	public trippinSkybox as Material

	def OnTriggerEnter(otherCollider as Collider):
		otherCollider.SendMessage("OnTouchedAltar")

		trigger = GetComponent[of SphereCollider]()
		trigger.enabled = false

		audio.Stop()

		audio.clip = flipClip
		audio.loop = false
		audio.Play()

		Invoke("changeSkybox", 5)
		Invoke("playTripping", 10)

	def changeSkybox():
		RenderSettings.skybox = trippinSkybox

	def playTripping():
		audio.clip = trippinClip
		audio.loop = true
		audio.Play()
