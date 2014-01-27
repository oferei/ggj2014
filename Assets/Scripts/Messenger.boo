#import UnityEngine
import System.Collections

class Messenger:

	callable MessageHandler(msg as Message)

	class Listener:

		[Property(script)]
		_script as UnityEngine.MonoBehaviour

		[Property(method)]
		_method as System.Reflection.MethodInfo

		#[Property(delegate)]
		#_delegate as MessageHandler #System.Delegate

	_listeners = Generic.Dictionary[of System.Type /*Message*/, Generic.List[of Listener]]()
	""" Enlisted listeners. """

	def listen(msgType as System.Type, listeningScript as UnityEngine.MonoBehaviour):
	""" Starts listening to messages derived from the specified type. """
	
		# verify type inherits from Message
		unless msgType.IsSubclassOf(Message) or msgType == Message:
			raise "Listened type is not a Message"

		# get list (create if necessary)
		if msgType not in _listeners:
			_listeners[msgType] = Generic.List[of Listener]()
		list = _listeners[msgType]
		
		# add listener
		functionName = Message.genFunctionName(msgType)
		method = listeningScript.GetType().GetMethod(functionName)
		#delegate = System.Delegate.CreateDelegate(MessageHandler, method) cast MessageHandler
		newListener = Listener(script: listeningScript, method: method/*, delegate: delegate*/)
		if newListener not in list:
			list.Add(newListener)
	
	def stopListening(msgType as System.Type, listeningScript as UnityEngine.MonoBehaviour):
	""" Stops listening to messages derived from the specified type. """
	
		# get list
		return if msgType not in _listeners
		list = _listeners[msgType]

		# remove listener
		for listener in list:
			if listener.script == listeningScript:
				list.Remove(listener)
				return

	def send(msg as Message):
	""" Dispatches a message. """

		# send message (to listeners of base classes too)
		for msgType in msg.baseClasses:
			# get list
			continue if msgType not in _listeners
			list as (Listener) = _listeners[msgType].ToArray()
			
			# send to all listeners
			for listener as Listener in list:
				if listener.method:
					listener.method.Invoke(listener.script, (msg,))
					#listener.delegate(msg)
	