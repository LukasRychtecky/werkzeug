goog.provide 'wzk.events.lst'

goog.require 'goog.events'
goog.require 'goog.async.Delay'

###*
  Listens on given field and dispatch the listener when the field is changed
  or it waits after typing

  @param {Element} field
  @param {function(goog.events.Event)} listener
  @param {number=} timeout
###
wzk.events.lst.onChangeOrKeyUp = (field, listener, timeout = 500) ->
  delay = null
  change = goog.events.listen field, goog.events.EventType.CHANGE, (e) ->
    delay.stop() if delay
    listener e

  goog.events.listen field, goog.events.EventType.KEYUP, (e) ->
    action = ->
      listener e
      goog.events.unlistenByKey change
    delay.stop() if delay
    delay = new goog.async.Delay action, timeout
    delay.start()
