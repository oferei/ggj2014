import UnityEngine

class TempleCenter (MonoBehaviour): 

	public flipClip as AudioClip
	public trippinClip as AudioClip
	public trippinSkybox as Material
	public powerUps as GameObject

	def OnTriggerEnter(otherCollider as Collider):
		otherCollider.SendMessage("OnTouchedAltar")

		trigger = GetComponent[of SphereCollider]()
		trigger.enabled = false

		audio.Stop()

		audio.clip = flipClip
		audio.loop = false
		audio.Play()

		Invoke("whenBlind", 5)
		Invoke("playTripping", 10)

	def whenBlind():
		RenderSettings.skybox = trippinSkybox
		powerUps.SetActive(true)

	def playTripping():
		audio.clip = trippinClip
		audio.loop = true
		audio.Play()
