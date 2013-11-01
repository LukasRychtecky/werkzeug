goog.provide 'wzk.async.Job'

class wzk.async.Job

  ###*
    @constructor
    @param {function(function())} callback a callback must take one callback that will be called at the end of the callback
  ###
  constructor: (@callback) ->

  ###*
    Executes this job.

    @param {function()} beforeDone
  ###
  exec: (beforeDone) ->
    @callback beforeDone
