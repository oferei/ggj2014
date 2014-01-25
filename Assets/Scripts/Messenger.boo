import UnityEngine

class Messenger:

	_listeners = {}
	""" Enlisted listeners. """

	def Listen(msgType as System.Type, listener as MonoBehaviour):
	""" Starts listening to messages derived from the specified type. """
	
		# verify type inherits from Message
		unless msgType.IsSubclassOf(Message) or msgType == Message:
			raise "Listened type is not a Message"

		# get list (create if necessary)
		if msgType not in _listeners:
			_listeners[msgType] = []
		list as List = _listeners[msgType]
		
		# add listener
		if listener not in list:
			list.Add(listener)
	
	def StopListening(msgType as System.Type, listener as MonoBehaviour):
	""" Stops listening to messages derived from the specified type. """
	
		# get list
		list as List = _listeners[msgType]
		return unless list

		# remove listener
		list.Remove(listener)

	def Send(msg as Message):
	""" Dispatches a message. """

		# send message (to listeners of base classes too)
		for msgType in msg.BaseClasses:
			# get list
			list = _listeners[msgType]
			continue unless list
			
			# send to all listeners
			for listener as MonoBehaviour in list:
				# invoke component method by name
				cb = listener.GetType().GetMethod(msg.FunctionName)
				if cb: cb.Invoke(listener, (msg,))
	