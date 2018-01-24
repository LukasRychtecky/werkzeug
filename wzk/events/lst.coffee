goog.provide 'wzk.events.lst'

goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'goog.events.KeyCodes'
goog.require 'goog.async.Delay'
goog.require 'wzk.dom.classes'

###*
  Listens on given field and dispatch the listener when the field is changed
  or it waits after typing

  @param {Element} field
  @param {function(goog.events.Event)} listener
  @param {number=} timeout
###
wzk.events.lst.onChangeOrKeyUp = (field, listener, timeout = 500) ->
  if wzk.dom.classes.hasAny(field, ['date', 'datetime']) or field.type in ['date', 'datetime']
    ignoreChange = false

    goog.events.listen field, goog.events.EventType.CHANGE, (e) ->
      listener(e) unless ignoreChange
      ignoreChange = false

    goog.events.listen field, goog.events.EventType.KEYUP, (e) ->
      listener e
      ignoreChange = true

  else

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


###*
  Fires a given listener when Enter is pressed.
  @param {Element} field
  @param {function(goog.events.Event)} listener
###
wzk.events.lst.onEnter = (field, listener) ->
  goog.events.listen(field, goog.events.EventType.KEYPRESS, (e) ->
    if e.keyCode is goog.events.KeyCodes.ENTER
      listener(e)
  )


###*
  Fires a given listener `onclick` event or when Enter is pressed.
  @param {Element} field
  @param {function(goog.events.Event)} listener
###
wzk.events.lst.onClickOrEnter = (field, listener) ->
  goog.events.listen(field, goog.events.EventType.CLICK, listener)
  wzk.events.lst.onEnter(field, listener)
