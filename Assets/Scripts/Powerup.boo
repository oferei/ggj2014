import UnityEngine

class Powerup (MonoBehaviour): 

	public skin as Skin

	def OnTriggerEnter(otherCollider as Collider):
		MessageSkin(skin)
		audio.Play()
