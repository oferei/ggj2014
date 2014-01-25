import UnityEngine

[RequireComponent(CharacterController)]

class FPSWalkerEnhanced (MonoBehaviour): 

	public walkSpeed = 6f
	public runSpeed = 11f

	# If limitDiagonalSpeed is true, diagonal speed (when strafing + moving forward or back) 
	# can't exceed normal move speed; otherwise it's about 1.4 times faster

	public limitDiagonalSpeed = true

	# If checked, the run key toggles between running and walking. Otherwise player runs if the key is held down and walks otherwise
	# There must be a button set up in the Input Manager called "Run"
	#toggleRun = false;

	public jumpSpeed = 8.0;
	public gravity = 20.0;

	origPosition as Vector3

	# Units that player can fall before a falling damage function is run. To disable, type "infinity" in the inspector
	fallingDamageThreshold = 10.0;

	# If the player ends up on a slope which is at least the Slope Limit as set on the character controller, then he will slide down
	slideWhenOverSlopeLimit = false

	# If checked and the player is on an object tagged "Slide", he will slide down it regardless of the slope limit
	slideOnTaggedObjects = false

	slideSpeed = 12.0

	# If checked, then the player can change direction while in the air
	airControl = false

	# Small amounts of this results in bumping when walking down slopes, but large amounts results in falling too fast
	antiBumpFactor = .75

	# Player must be grounded for at least this many physics frames before being able to jump again; set to 0 to allow bunny hopping 
	antiBunnyHopFactor = 1

	private moveDirection = Vector3.zero
	private grounded = false
	private controller as CharacterController
	private myTransform as Transform
	private speed as single
	private hit as RaycastHit
	private fallStartLevel as single
	private falling = false
	private slideLimit as single
	private rayDistance as single
	private contactPoint as Vector3
	private playerControl = false
	private jumpTimer as int

	def Start ():
		controller = GetComponent(CharacterController)
		myTransform = transform
		speed = walkSpeed
		rayDistance = controller.height * .5 + controller.radius
		slideLimit = controller.slopeLimit - .1
		jumpTimer = antiBunnyHopFactor
		origPosition = myTransform.position

	def FixedUpdate():
		inputX = Input.GetAxis("Horizontal");
		inputY = Input.GetAxis("Vertical");
		# If both horizontal and vertical are used simultaneously, limit speed (if allowed), so the total doesn't exceed normal move speed
		inputModifyFactor = (.7071 if (inputX != 0.0 and inputY != 0.0 and limitDiagonalSpeed) else 1.0)

		if grounded:
			sliding = false
			# See if surface immediately below should be slid down. We use this normally rather than a ControllerColliderHit point,
			# because that interferes with step climbing amongst other annoyances
			if Physics.Raycast(myTransform.position, -Vector3.up, hit, rayDistance):
				if Vector3.Angle(hit.normal, Vector3.up) > slideLimit:
					sliding = true
			# However, just raycasting straight down from the center can fail when on steep slopes
			# So if the above raycast didn't catch anything, raycast down from the stored ControllerColliderHit point instead
			else:
				Physics.Raycast(contactPoint + Vector3.up, -Vector3.up, hit)
				if Vector3.Angle(hit.normal, Vector3.up) > slideLimit:
					sliding = true


			# If we were falling, and we fell a vertical distance greater than the threshold, run a falling damage routine
			if falling:
				falling = false
				if myTransform.position.y < fallStartLevel - fallingDamageThreshold:
					FallingDamageAlert(fallStartLevel - myTransform.position.y)

			# If running isn't on a toggle, then use the appropriate speed depending on whether the run button is down
			#if not toggleRun:
			#	speed = (runSpeed if Input.GetButton("Run") else walkSpeed)

			# If sliding (and it's allowed), or if we're on an object tagged "Slide", get a vector pointing down the slope we're on
			if (sliding and slideWhenOverSlopeLimit) or (slideOnTaggedObjects and hit.collider.tag == "Slide"):
				hitNormal = hit.normal
				moveDirection = Vector3(hitNormal.x, -hitNormal.y, hitNormal.z)
				Vector3.OrthoNormalize (hitNormal, moveDirection)
				moveDirection *= slideSpeed
				playerControl = false

			# Otherwise recalculate moveDirection directly from axes, adding a bit of -y to avoid bumping down inclines
			else:
				moveDirection = Vector3(inputX * inputModifyFactor, -antiBumpFactor, inputY * inputModifyFactor)
				moveDirection = myTransform.TransformDirection(moveDirection) * speed
				playerControl = true


			# Jump! But only if the jump button has been released and player has been grounded for a given number of frames
			if not Input.GetButton("Jump"):
				jumpTimer++
			elif jumpTimer >= antiBunnyHopFactor:
				moveDirection.y = jumpSpeed;
				jumpTimer = 0;


		else:
			# If we stepped over a cliff or something, set the height at which we started falling
			if not falling:
				falling = true;
				fallStartLevel = myTransform.position.y;


			# If air control is allowed, check movement but don't touch the y component
			if airControl and playerControl:
				moveDirection.x = inputX * speed * inputModifyFactor
				moveDirection.z = inputY * speed * inputModifyFactor
				moveDirection = myTransform.TransformDirection(moveDirection)


		# Apply gravity
		moveDirection.y -= gravity * Time.deltaTime;

		# Move the controller, and set grounded true or false depending on whether we're standing on something
		moveDirection.y = 0
		grounded = ((controller.Move(moveDirection * Time.deltaTime) & CollisionFlags.Below) != 0)
		grounded = true
		myTransform.position.y = origPosition.y

	def Update ():
		# If the run button is set to toggle, then switch between walk/run speed. (We use Update for this...
		# FixedUpdate is a poor place to use GetButtonDown, since it doesn't necessarily run every frame and can miss the event)

		#if toggleRun and grounded and Input.GetButtonDown("Run"):
		#	speed = (runSpeed if speed == walkSpeed else walkSpeed)
		pass


	# Store point that we're in contact with for use in FixedUpdate if needed
	def OnControllerColliderHit (hit as ControllerColliderHit):
		contactPoint = hit.point


	# If falling damage occured, this is the place to do something about it. You can make the player
	# have hitpoints and remove some of them based on the distance fallen, add sound effects, etc.
	def FallingDamageAlert (fallDistance as single):
		Debug.Log ("Ouch! Fell " + fallDistance + " units!")