import UnityEngine

[RequireComponent(CharacterController)]

class BadasFPSWalker (MonoBehaviour): 

	public forwardSpeed as single = 17.0 # meters per second
	public reverseSpeed as single = 5.0 # meters per second
	public reverseTurnThreshold as single = 120 # degrees
	public rotationSpeed as single = 35.0 # degrees per second
	public thrust as single = 12 # meters per second^2
	public gravity as single = 9.8 # meters per second^2
	
	public reverseWalkThreshold as single = 100 # degrees
	public accelerationDampingZ as single = 3
	public accelerationDampingX as single = 7
	public maxReverseTime as single = 2.0 # seconds
	public glueStrength as single = 0.02

	# player input
	_prevHoriz as single = 0.0
	_prevVert as single = 0.0
	_prevInputDirection as Vector3
	_moveStartTime as single

	# movement state
	_grounded = false
	_moveDirection = Vector3.zero

	_pelvis as Transform
	_cameraTorso as Transform
	_camera as Transform
	_torso as Transform
	_thrusterEmitter as ParticleEmitter
	
	_controller as CharacterController
	_groundLayerMask as int

	def Awake ():
		_pelvis = transform.Find("BADAS/Body/Pelvis")
		assert _pelvis
		_cameraTorso = transform.Find("BADAS/Body/CameraTorso")
		assert _cameraTorso
		_camera = transform.Find("BADAS/Body/CameraTorso/Camera")
		assert _camera
		_torso = transform.Find("BADAS/Body/Pelvis/Torso 0/Torso")
		assert _torso
		_thrusterEmitter = transform.Find("Thruster").particleEmitter
		assert _thrusterEmitter
		
		_controller = GetComponent(CharacterController)
	
		# ground only mask
		_groundLayerMask = 1 << LayerMask.NameToLayer("Ground")

	def FixedUpdate ():

		#~ if _grounded:
		# we are grounded, so recalculate move direction from axes
		inputDirection = GetInputVector()
		if inputDirection != Vector3.zero and _prevInputDirection == Vector3.zero:
			_moveStartTime = Time.time
		_prevInputDirection = inputDirection
		
		# any movement key pressed?
		if inputDirection != Vector3.zero:
			# get desired move direction from player
			desiredMoveDirection = _camera.TransformDirection(inputDirection)
			desiredMoveDirection.y = 0
			#Debug.DrawRay(_camera.position, desiredMoveDirection * 20, Color.red)
			
			# calculate pelvis facing
			pelvisDirection = _pelvis.forward
			assert pelvisDirection.y == 0
			#Debug.DrawRay(_pelvis.position, pelvisDirection * 20, Color.blue)
			
			if _grounded:
				# calculate angle between pelvis facing and desired movement direction
				deltaMoveAngle = Vector3.Angle(desiredMoveDirection, pelvisDirection)

				# determine desired pelvis direction (reverse or not?)
				desiredPelvisDirection = desiredMoveDirection
				# allow reverse unless player is holding the Forward key
				if inputDirection.z != 1 and Time.time - _moveStartTime < maxReverseTime:
					if deltaMoveAngle > reverseTurnThreshold:
						desiredPelvisDirection = -desiredPelvisDirection
				
				# determine walking direction
				if deltaMoveAngle > reverseWalkThreshold:
					# reverse
					desiredSpeed = -reverseSpeed
				else:
					# forward
					desiredSpeed = forwardSpeed
			else:
				# in air
				desiredPelvisDirection = desiredMoveDirection

			# rotate towards
			yRotation = GetYRotationAngle(pelvisDirection, desiredPelvisDirection)
			
			# prefer rotating towards camera-forward (back towards player)
			if Mathf.Abs(yRotation - 180) < 3 and Mathf.Abs(Vector3.Angle(pelvisDirection, _camera.forward) - 90) < 50:
				if Vector3.Cross(_camera.forward, pelvisDirection).y > 0:
					# rotate left
					yRotation = 360 - rotationSpeed * Time.deltaTime
				else:
					# rotate right
					yRotation = rotationSpeed * Time.deltaTime
			else:
				yRotation = ClampAngle(yRotation, rotationSpeed * Time.deltaTime)
			newRotation = Quaternion.AngleAxis(yRotation, Vector3.up)
		else:
			# player not touching any key
			if _grounded:
				desiredSpeed = 0
			newRotation = Quaternion.identity
		
		# rotate body (while preserving camera & torso rotations)
		origCameraTorsoRotation = _cameraTorso.rotation
		origTorsoRotation = _torso.rotation
		transform.rotation *= newRotation
		_cameraTorso.rotation = origCameraTorsoRotation
		_torso.rotation = origTorsoRotation
		
		# accelerate
		if _grounded:
			Accelerate(desiredSpeed)

		#~ else:
			#~ # in the air
			#~ newRotation = Quaternion.identity

		# thrusters
		if Input.GetButton ("Jump"):
			_moveDirection.y += thrust * Time.deltaTime
		_thrusterEmitter.emit = Input.GetButton ("Jump")

		# Apply gravity
		_moveDirection.y -= gravity * Time.deltaTime

		# Move the controller
		wasGrounded = _grounded
		flags = _controller.Move(_moveDirection * Time.deltaTime)
		_grounded = (flags & CollisionFlags.Below) != 0
		
		if _grounded:
			# TODO: change this - allow movement to align with slope
			_moveDirection.y = 0
		
		# glue to floor
		if wasGrounded and not _grounded and not Input.GetButton ("Jump"):
			# find ground below
			hit as RaycastHit
			ray = Ray(transform.position + Vector3(0, 0.001, 0), -Vector3.up)
			#~ Debug.DrawRay(ray.origin, ray.direction * 30)
			if Physics.Raycast(ray, hit, 30, _groundLayerMask):
				# found ground
				if hit.distance * Time.deltaTime < glueStrength:
					#~ Debug.Log("descending (${hit.distance * Time.deltaTime})")
					flags = _controller.Move(hit.point - transform.position)
					_grounded = true
				#~ else:
					#~ Debug.Log("breaking off ground (${hit.distance * Time.deltaTime})")
			#~ else:
				#~ Debug.Log("off the edge!")
		
		wasGrounded = _grounded
			

	def GetInputVector() as Vector3:
		# get horizontal axis
		horiz = Input.GetAxis("Horizontal")
		horizUnpressed = Mathf.Abs(horiz) < Mathf.Abs(_prevHoriz)
		_prevHoriz = horiz
		if horizUnpressed:
			horiz = 0
		
		if horiz > 0:
			horiz = 1
		elif horiz < 0:
			horiz = -1
		
		# get vertical axis
		vert = Input.GetAxis("Vertical")
		vertUnpressed = Mathf.Abs(vert) < Mathf.Abs(_prevVert)
		_prevVert = vert
		if vertUnpressed:
			vert = 0
		
		if vert > 0:
			vert = 1
		elif vert < 0:
			vert = -1
		
		# return combined vector
		return Vector3(horiz, 0, vert)

	def ClampAngle(angle as single, maxAngle as single):
	""" Ensures angle is not larger than a value. """
		
		if angle > 180:
			return Mathf.Max(angle, 360 - maxAngle)
		else:
			return Mathf.Min(angle, maxAngle)

	def GetYRotationAngle(fromDirection as Vector3, toDirection as Vector3) as single:
		angle = Vector3.Angle(fromDirection, toDirection)
		if Vector3.Cross(fromDirection, toDirection).y > 0:
			return angle
		else:
			return 360 - angle

	def Accelerate(desiredSpeed as single):
		currentZSpeed = Vector3.Project(_moveDirection, _pelvis.forward)
		currentXSpeed = Vector3.Project(_moveDirection, _pelvis.right)
		desiredZSpeed = _pelvis.forward * desiredSpeed
		desiredXSpeed = Vector3.zero

		ZDamping =  Mathf.Clamp01(accelerationDampingZ * Time.deltaTime)
		newZSpeed = desiredZSpeed * ZDamping + currentZSpeed * (1-ZDamping)
		XDamping = Mathf.Clamp01(accelerationDampingX * Time.deltaTime)
		newXSpeed = desiredXSpeed * XDamping + currentXSpeed * (1-XDamping)
		
		_moveDirection = newXSpeed + newZSpeed
		
	#~ def OnControllerColliderHit(hit as ControllerColliderHit):
		#~ Debug.Log("OnControllerColliderHit ${hit.transform.name} ${LayerMask.LayerToName(hit.gameObject.layer)}")
