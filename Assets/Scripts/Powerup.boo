import UnityEngine

class Powerup (MonoBehaviour): 

	public target as GameObject
	public material as Material

	def OnTriggerEnter(otherCollider as Collider):
		target.renderer.material = material
