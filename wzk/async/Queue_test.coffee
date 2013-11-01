suite 'wzk.async.Queue', ->

  queue = null

  addJob = (time) ->
    queue.addCallback (beforeDone) ->
      setTimeout ->
        beforeDone()
      , time
  
  setup ->
    queue = new wzk.async.Queue()
    
  test 'Should call a one callback when all async jobs are done', (done) ->
    # short times for faster tests
    addJob 10
    addJob 30
    addJob 20
    addJob 10
    addJob 30

    queue.exec ->
      done() if queue.allDone()

  test 'Jobs should be running', ->
    addJob 50
    addJob 30

    assert.isFalse queue.isOnCall()

    queue.exec ->
      assert.isFalse queue.isOnCall()
    assert.isTrue queue.isOnCall()
