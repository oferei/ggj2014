import UnityEngine

/// MouseLook rotates the transform based on the mouse delta.
/// Minimum and Maximum values can be used to constrain the possible rotation

/// To make an FPS style character:
/// - Create a capsule.
/// - Add a rigid body to the capsule
/// - Add the MouseLook script to the capsule.
///   -> Set the mouse look to use LookX. (You want to only turn character but not tilt it)
/// - Add FPSWalker script to the capsule

/// - Create a camera. Make the camera a child of the capsule. Reset it's transform.
/// - Add a MouseLook script to the camera.
///   -> Set the mouse look to use LookY. (You want the camera to tilt up and down like a head. The character already turns.)
[AddComponentMenu("Camera-Control/Mouse Look")]
class MouseLook (MonoBehaviour): 

	enum RotationAxes:
		MouseXAndY = 0
		MouseX = 1
		MouseY = 2
	public axes = RotationAxes.MouseXAndY
	public sensitivityX as single = 15
	public sensitivityY as single = 15

	public minimumX as single = -360F
	public maximumX as single = 360F

	public minimumY as single = -60F
	public maximumY as single = 60F

	rotationX as single = 0F
	rotationY as single = 0F
	
	originalRotation as Quaternion

	def Update():
		if axes == RotationAxes.MouseXAndY:
			// Read the mouse input axis
			rotationX += Input.GetAxis("Mouse X") * sensitivityX
			rotationY += Input.GetAxis("Mouse Y") * sensitivityY

			rotationX = ClampAngle(rotationX, minimumX, maximumX)
			rotationY = ClampAngle(rotationY, minimumY, maximumY)
			
			xQuaternion = Quaternion.AngleAxis(rotationX, Vector3.up)
			yQuaternion = Quaternion.AngleAxis(rotationY, Vector3.left)
			
			transform.localRotation = originalRotation * xQuaternion * yQuaternion
		elif axes == RotationAxes.MouseX:
			rotationX += Input.GetAxis("Mouse X") * sensitivityX
			rotationX = ClampAngle(rotationX, minimumX, maximumX)

			xQuaternion = Quaternion.AngleAxis(rotationX, Vector3.up)
			transform.localRotation = originalRotation * xQuaternion
		else:
			rotationY += Input.GetAxis("Mouse Y") * sensitivityY
			rotationY = ClampAngle(rotationY, minimumY, maximumY)

			yQuaternion = Quaternion.AngleAxis(rotationY, Vector3.left)
			transform.localRotation = originalRotation * yQuaternion
	
	def Start():
		// Make the rigid body not change rotation
		if rigidbody:
			rigidbody.freezeRotation = true
		originalRotation = transform.localRotation
	
	static def ClampAngle(angle as single, min as single, max as single) as single:
		if angle < -360:
			angle += 360
		if angle > 360:
			angle -= 360
		return Mathf.Clamp(angle, min, max)

	def reset():
		originalRotation = transform.localRotation
		rotationX = 0
		rotationY = 0
