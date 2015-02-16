suite 'wzk.net.FlashMiddleware', ->
  FlashMiddleware = wzk.net.FlashMiddleware

  flash = null

  class Flash

    constructor: ->
      @error = null
      @msgs = {}

    addError: (@error) ->

    addMessage: (msg, type) ->
      @msgs[type] = msg


  assertFlashError = (flash, error) ->
    assert.equal flash.error, error

  setup ->
    flash = new Flash()

  test 'Should display an overridden message instead of a response message', ->
    response =
      error: 'response message'
    msgs =
      '401': 'overridden'
    mid = new FlashMiddleware(flash, msgs)

    mid.apply(flash, 401)
    assertFlashError flash, null

  test 'Should display messages', ->
    response =
      messages:
        info: 'success'
    mid = new FlashMiddleware(flash, {})

    mid.apply(response, 200)
    assert.equal response.messages.info, flash.msgs.info

  test 'Should display an error message', ->
    response =
      error: 'Error'
    mid = new FlashMiddleware(flash, {})

    mid.apply(response, 500)
    assertFlashError flash, response.error

  test 'Should display all errors from response as an array', ->
    response =
      errors: ['a', 'b']
    mid = new FlashMiddleware(flash, {})

    mid.apply(response, 200)
    assertFlashError flash, response.errors

  test 'Should display all errors from response as a string', ->
    response =
      errors: "['a', 'b']"
    mid = new FlashMiddleware(flash, {})

    mid.apply(response, 200)
    assertFlashError flash, response.errors

  test 'Should display default error', ->
    mid = new FlashMiddleware(flash, {})

    mid.error(401)
    assertFlashError flash, FlashMiddleware.MSGS.error

  test 'Should not display default error', ->
    msgs =
      '401': null
    mid = new FlashMiddleware(flash, msgs)

    mid.error(401)
    assertFlashError flash, null

  test 'Should display overridden message', ->
    msgs =
      '401': 'overridden'
    mid = new FlashMiddleware(flash, msgs)

    mid.error(401)
    assertFlashError flash, msgs['401']
