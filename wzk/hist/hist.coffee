goog.provide 'wzk.hist'

goog.require 'goog.History'

###*
  Setups history listener
  @param {function(?)} callback
###
wzk.hist.historyHandler = (callback) ->
  history = new goog.History()
  history.setEnabled true
  history.listen goog.history.EventType.NAVIGATE, (event) ->
    callback(event)
