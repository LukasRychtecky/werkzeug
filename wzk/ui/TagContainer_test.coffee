suite 'wzk.ui.TagContainer', ->
  TagContainer = wzk.ui.TagContainer
  Event = wzk.ui.TagContainer.EventType

  cont = null
  dom = null
  model = null
  doc = null
  tag = null

  buildTag = (model) ->
    t = new wzk.ui.Tag(model, null, dom)
    t.setModel(model)
    t

  fireRemoveEvent = (tag) ->
    tag.dispatchEvent(wzk.ui.Tag.EventType.REMOVE)

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    </body>
    </html>
    """
    model = 'Foo'
    dom = new wzk.dom.Dom doc
    cont = new TagContainer(null, null, dom)
    tag = buildTag(model)

  test 'Should fires ADD with the container', (done) ->
    goog.events.listen cont, Event.ADD, (e) ->
      assert.equal e.target, cont
      done()

    cont.add(tag)

  test 'Should fires ADD_TAG with the tag', (done) ->
    goog.events.listen cont, Event.ADD_TAG, (e) ->
      assert.equal e.target, tag
      done()

    cont.add(tag)

  test 'Should fires REMOVE with the container', (done) ->
    goog.events.listen cont, Event.REMOVE, (e) ->
      assert.equal e.target, cont
      done()

    cont.add(tag)
    fireRemoveEvent(tag)

  test 'Should fires REMOVE_TAG with the container', (done) ->
    goog.events.listen cont, Event.REMOVE_TAG, (e) ->
      assert.equal e.target, tag
      done()

    cont.add(tag)
    fireRemoveEvent(tag)

  test 'Should not be empty', ->
    cont.add(tag)
    assert.isFalse cont.isEmpty()

  test 'Should be empty', ->
    assert.isTrue cont.isEmpty()
