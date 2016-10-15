class wzk.debug.ErrorReporter

  ###*
    @param {function(string)|undefined=} log
  ###
  constructor: (@log = ->) ->

  ###*
    @param {function(string)} log
  ###
  setLog: (@log) ->

  ###*
    @param {Object} e an exception
  ###
  report: (e) ->
    @log(e.message, String(e.stack))
