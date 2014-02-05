suite 'wzk.ui.Flash', ->
  Flash = wzk.ui.Flash

  flash = null
  dom = null
  parent = null

  mockEl = ->
    appendChild: ->
    querySelector: ->
      mockEl()
    attachEvent: ->
    style: {}

  mockDom = ->
    createDom: ->
      mockEl()
    el: ->
      mockEl()
    createTextNode: ->
      {}
    setTextContent: ->
    getDocument: ->
      mockDom()
    body: mockEl()

  setup ->
    parent = mockEl()
    dom = mockDom()
    flash = new Flash dom: dom

  test 'Should add an error message without a fade out and a close icon', ->
    flashes = flash.addMessage 'Error', 'error'

    assert.equal flashes.length, 1
    msg = flashes.pop()
    assert.isFalse msg.fadeOut
    assert.isFalse msg.closable

  test 'Should add an info message with a close icon and without a fade out', ->
    flashes = flash.addMessage 'Info', 'info', false

    msg = flashes.pop()
    assert.isFalse msg.fadeOut
    assert.isTrue msg.closable
