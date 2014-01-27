import UnityEngine

class SkinApply (MonoBehaviour): 

	public type as Skin.Type

	def OnEnable ():
		God.inst.hermes.listen(MessageSkin, self)

	def OnDisable ():
		God.inst.hermes.stopListening(MessageSkin, self)

	def OnMsgSkin (msg as MessageSkin):
		renderer.material = msg.skin.getMaterial(type)
