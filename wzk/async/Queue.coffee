goog.provide 'wzk.async.Queue'

goog.require 'wzk.async.Job'

###*
  Handles an async queue of jobs. When all jobs are done, onDone callback will be called.
###
class wzk.async.Queue

  ###*
    @constructor
  ###
  constructor: ->
    @jobs = []
    @onDone = null
    @onCallCounter = 0
    @execRunning = false
    
  ###*
    Sets a callback, that will be called when all jobs are done
  
    @param {function()} onDone
  ###
  setOnDone: (onDone) ->
    @onDone = onDone

  ###*
    Adds a job into the queue

    @param {wzk.async.Job} job
  ###
  addJob: (job) ->
    @jobs.push job

  ###*
    Adds a callback into the queue. The callback must take a callback (beforeDone), that will be called the before this callback is done.
  
    @param {function(function())} clb
  ###
  addCallback: (clb) ->
    @addJob new wzk.async.Job clb

  ###*
    Returns true when all jobs are done, otherwise false
  
    @return {boolean}
  ###
  allDone: ->
    @onCallCounter is 0

  ###*
    Return true when jobs are running, otherwise false.

    @return {boolean}
  ###
  isOnCall: ->
    @execRunning

  ###*
    Executes the queue.

    @param {?function()=} onDone a callback will be called, when all jobs are done
  ###
  exec: (onDone = null) ->
    @onDone = onDone if onDone?

    @onCallCounter = @jobs.length

    done = =>
      @onCallCounter--

      if @allDone()
        @execRunning = false
        @onDone() if @onDone?

    @execRunning = true
    for job in @jobs
      job.exec done
