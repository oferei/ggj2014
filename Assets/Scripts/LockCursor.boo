import UnityEngine

class LockCursor (MonoBehaviour): 

	def Start ():
		# Start out in paused mode in web player
		
		if Application.platform in [
					RuntimePlatform.OSXWebPlayer,
					RuntimePlatform.WindowsWebPlayer,
					RuntimePlatform.WindowsEditor]:
			SetPause(true)
		else:
			SetPause(false)
			Screen.lockCursor = true
	
	def OnApplicationQuit ():
		Time.timeScale = 1

	def SetPause (pause as bool):
		Input.ResetInputAxes()
		gos as (GameObject) = FindObjectsOfType(GameObject)
		for go in gos:
			go.SendMessage("DidPause", pause, SendMessageOptions.DontRequireReceiver)
		
		transform.position = Vector3.zero
		
		if pause:
			Time.timeScale = 0
			transform.position = Vector3 (.5, .5, 0)
			if guiText:
				guiText.anchor = TextAnchor.MiddleCenter
		else:
			if guiText:
				guiText.anchor = TextAnchor.UpperLeft
			transform.position = Vector3(0, 1, 0)
			Time.timeScale = 1

	def DidPause (pause as bool):
		if pause:
			# Show the button again
			if guiText:
				guiText.enabled = true
				guiText.text = "Click to start playing"
		else:
			# Disable the button
			if guiText:
				guiText.enabled = true
				guiText.text = "Escape to show the cursor"

	def OnMouseDown ():
		# Lock the cursor
		Screen.lockCursor = true

	_wasLocked = false

	def Update ():
		if Input.GetMouseButton(0):
			Screen.lockCursor = true
		
		# Did we lose cursor locking?
		# eg. because the user pressed escape
		# or because he switched to another application
		# or because some script set Screen.lockCursor = false;
		if not Screen.lockCursor and _wasLocked:
			_wasLocked = false
			SetPause(true)
		# Did we gain cursor locking?
		elif Screen.lockCursor and not _wasLocked:
			_wasLocked = true
			SetPause(false)
	  