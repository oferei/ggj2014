#import UnityEngine

class Message(Object):

	functionName:
	""" Method name in listener components """
		get:
			return _functionName
	_functionName as string

	static def genFunctionName(type as System.Type):
		return 'OnMsg' + type.ToString()[7:]

	baseClasses:
	""" Inheritance route """
		get:
			return _baseClasses
	_baseClasses as (System.Type)

	def constructor():
	""" Creates and dispatches a message. """

		# replace 'Message' with 'OnMsg'
		_functionName = 'OnMsg' + self.GetType().ToString()[7:]

		_baseClasses = array(System.Type, getBaseClasses())

		God.inst.hermes.send(self)

	protected def getBaseClasses():
	""" Generates inheritance route """
	
		msgType = self.GetType()
		while msgType != Message:
			yield msgType
			msgType = msgType.BaseType
		yield Message
