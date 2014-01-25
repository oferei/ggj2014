#import UnityEngine

class Message:

	FunctionName:
	""" Method name in listener components """
		get:
			return _functionName
	_functionName as string

	BaseClasses:
	""" Inheritance route """
		get:
			return _baseClasses
	_baseClasses as (System.Type)

	def constructor():
	""" Creates and dispatches a message. """

		# replace 'Message' with 'OnMsg'
		_functionName = 'OnMsg' + self.GetType().ToString()[7:]

		_baseClasses = array(System.Type, GetBaseClasses())

		God.Inst.Hermes.Send(self)

	protected def GetBaseClasses():
	""" Generates inheritance route """
	
		msgType = self.GetType()
		while msgType != Message:
			yield msgType
			msgType = msgType.BaseType
		yield Message
