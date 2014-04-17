suite 'wzk.ui.Tag', ->
  Tag = wzk.ui.Tag
  Event = goog.events.EventType

  tag = null
  dom = null
  doc = null

  fireEvent = (type, e = {}) ->
    e.type = type
    e.target = tag.getIcon()
    tag.getElement()._listeners[type].false[0].listener.listener(e)

  fireClick = ->
    fireEvent(Event.CLICK)

  fireEnter = ->
    fireEvent(Event.KEYUP, keyCode: goog.events.KeyCodes.ENTER)

  fireEscape = ->
    fireEvent(Event.KEYUP, keyCode: goog.events.KeyCodes.ESC)

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc
    tag = new Tag('Foo', wzk.ui.TagRenderer.getInstance(), dom)
    tag.render doc.body

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
