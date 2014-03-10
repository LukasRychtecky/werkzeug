suite 'wzk.ui.Tag', ->
  Tag = wzk.ui.Tag
  Event = goog.events.EventType

  tag = null
  dom = null
  doc = null

  mockDom = ->
    dom =
      createDom: (tag) ->
        mockEl(tag.toUpperCase())
      getDocument: ->
        doc
    dom

  mockDoc = ->
    doc = document
    doc.createTextNode = ->
      {}
    doc

  mockEl = (tag) ->
    el =
      appendChild: ->
      insertBefore: ->
      ownerDocument: doc
      getAttributeNode: ->
        {}
      attachEvent: ->
      tagName: tag
      remove: ->
      events: {}
      addEventListener: (type, proxy) ->
        @events[type] = proxy
    el

  fireEvent = (type, e = {}) ->
    e.type = type
    tag.getElement().events[type](e)

  fireClick = ->
    fireEvent(Event.CLICK)

  fireEnter = ->
    fireEvent(Event.KEYUP, keyCode: goog.events.KeyCodes.ENTER)

  fireEscape = ->
    fireEvent(Event.KEYUP, keyCode: goog.events.KeyCodes.ESC)

  setup ->
    doc = mockDoc()
    dom = mockDom()
    tag = new Tag('Foo', wzk.ui.TagRenderer.getInstance(), dom)
    tag.createDom()

  test 'Should fire REMOVE on click', (done) ->
    goog.events.listen tag, wzk.ui.Tag.EventType.REMOVE, (e) ->
      done()
      assert.equal e.target, tag

    fireClick()

  test 'Should fire REMOVE on enter key', (done) ->
    goog.events.listen tag, wzk.ui.Tag.EventType.REMOVE, (e) ->
      done()
      assert.equal e.target, tag

    fireEnter()

  test 'Should not fire REMOVE on escape key', ->
    goog.events.listen tag, wzk.ui.Tag.EventType.ESC, ->
      assert.fail 'Should not fire on escape key!'

    fireEscape()
