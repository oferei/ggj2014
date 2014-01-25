import UnityEngine

class BadasMouseLook (MonoBehaviour): 

	public sensitivityX as single = 2
	public sensitivityY as single = 2
	
	#public minimumX as single = -360
	#public maximumX as single = 360

	public minimumY as single = -30
	public maximumY as single = 25

	public enableAcceleration = true

	public accelerationSensitivityX as single = 3.33
	public maxAccelerationX as single = 2

	public accelerationSensitivityY as single = 2
	public maxAccelerationY as single = 1.5
	
	static final _e as single = 2.71828183

	_camera as Transform

	_rotationX as single = 0
	_rotationY as single = 0
	
	_originalCameraRotation as Quaternion

	_lastXDiffs = []
	_lastYDiffs = []

	def Start ():
		_camera = transform.Find("BADAS/Body/CameraTorso")
		assert _camera
		
		# Make the rigid body not change rotation
		#if rigidbody:
		#	rigidbody.freezeRotation = true
		_originalCameraRotation = _camera.transform.rotation
		
		God.Inst.Player = transform.Find("BADAS")

	def Update ():
		# read the mouse input and apply acceleration
		xDiff = GetAcceleratedAxis("Mouse X", _lastXDiffs, accelerationSensitivityX, maxAccelerationX)
		yDiff = GetAcceleratedAxis("Mouse Y", _lastYDiffs, accelerationSensitivityY, maxAccelerationY)

		# calculate new angles
		_rotationX += xDiff * sensitivityX
		_rotationY += yDiff * sensitivityY

		# apply limits
		#_rotationX = ClampAngle (_rotationX, minimumX, maximumX)
		_rotationY = ClampAngle (_rotationY, minimumY, maximumY)
		
		# rotate
		xQuaternion = Quaternion.AngleAxis (_rotationX, Vector3.up)
		yQuaternion = Quaternion.AngleAxis (_rotationY, Vector3.left)
		
		_camera.transform.rotation = _originalCameraRotation * xQuaternion * yQuaternion

	public static def ClampAngle (angle as single, min as single, max as single):
		if angle < -360:
			angle += 360
		if angle > 360:
			angle -= 360
		return Mathf.Clamp (angle, min, max)

	public static def Avg(l as List):
		sum as single = 0
		for x as single in l:
			sum += x
		return sum / len(l)

	def GetAcceleratedAxis(axisName as string, recordList as List, accelerationSensitivity as single, maxAcceleration as single):
		# read the mouse input axis
		axisDiff = Input.GetAxis(axisName)
		unless enableAcceleration:
			return axisDiff

		# keep value
		recordList.Add(axisDiff)
		if len(recordList) > 30:
			recordList.RemoveAt(0)
		
		# calculate recent average mouse movement
		recentDiff = Avg(recordList)
		relRecentDiff = Mathf.Clamp01(Mathf.Abs(recentDiff) * accelerationSensitivity)
		#~ if axisName == "Mouse X":
			#~ Debug.Log("recentDiff: ${recentDiff}, relRecentDiff: ${relRecentDiff}")
		relRecentDiff *= _e ** maxAcceleration
		
		# accelerate mouse movement (don't ever slow)
		if relRecentDiff > _e:
			acceleration = Mathf.Log(relRecentDiff)
		else:
			acceleration = 1
		
		#~ if axisName == "Mouse X":
			#~ Debug.Log("relRecentDiff: ${relRecentDiff}, acceleration: ${acceleration}")
		
		# accelerate mouse movement
		return axisDiff * acceleration
