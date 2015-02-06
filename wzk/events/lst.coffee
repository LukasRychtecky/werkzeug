goog.provide 'wzk.events.lst'

goog.require 'goog.events'

###*
  Listens on given field and dispatch the listener when the field is changed
  or it waits after typing

  @param {Element} field
  @param {function(goog.events.Event)} listener
  @param {number=} timeout
###
wzk.events.lst.onChangeOrKeyUp = (field, listener, timeout = 500) ->
  ignoreChange = false

  goog.events.listen field, goog.events.EventType.CHANGE, (e) ->
    listener(e) unless ignoreChange
    ignoreChange = false

  goog.events.listen field, goog.events.EventType.KEYUP, (e) ->
    listener e
    ignoreChange = true
