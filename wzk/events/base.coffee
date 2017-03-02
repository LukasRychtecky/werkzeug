goog.provide 'wzk.events'

goog.require 'goog.dom'


###*
  Dispatches a native event on a given element.

  @param {EventTarget} el The node to listen to events on.
  @param {string} type an event type that is goging to be dispatched
###
wzk.events.dispatchNativeEvent = (el, type) ->
  if goog.isFunction(goog.dom.getDocument().createEvent)
    e = goog.dom.getDocument().createEvent('HTMLEvents')
    e.initEvent(type, false, true)
    el.dispatchEvent(e)
  else
    el.fireEvent('on' + type)
  undefined
