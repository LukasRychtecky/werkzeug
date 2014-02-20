goog.provide 'wzk.history'

goog.require 'goog.History'

###*
  Setups history listener
  @param {function} callback
###
wzk.history.historyHandler = (callback) ->
  history = new goog.History()
  history.setEnabled true
  goog.events.listen history, goog.history.EventType.NAVIGATE, (event) ->
    callback(event)
