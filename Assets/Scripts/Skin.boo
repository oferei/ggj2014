import UnityEngine

class Skin:
	public enum Type:
		TempleOuter
		TempleInner
		TempleColumns
		TempleColumns5

	public templeOuterMaterial as Material
	public templeInnerMaterial as Material
	public templeColumnsMaterial as Material
	public templeColumns5Material as Material

	def getMaterial(type as Type) as Material:
		return templeOuterMaterial if type == Type.TempleOuter
		return templeInnerMaterial if type == Type.TempleInner
		return templeColumnsMaterial if type == Type.TempleColumns
		return templeColumns5Material if type == Type.TempleColumns5
