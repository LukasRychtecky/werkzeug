suite 'wzk.ui.form.MirrorInput', ->
  MirrorInput = wzk.ui.form.MirrorInput

  input = null
  target = null
  doc = null
  dom = null

  type = (el, val) ->
    el.value += val
    el._listeners['keyup']?.false[0]?.listener.listener({})

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    <input type="text" name="target" id="target">
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc
    target = doc.getElementById 'target'
    target.value = ''

  test 'Should watch an element', ->
    input = new MirrorInput dom: dom, target: target
    input.render doc.body

    type target, 'a'
    assert.equal input.getValue(), target.value

    type target, 'b'
    assert.equal input.getValue(), target.value

  test 'Should stop watching after its value has been changed', ->
    input = new MirrorInput dom: dom, target: target
    input.render doc.body

    type target, 'a'
    assert.equal input.getValue(), target.value

    type input.getElement(), 'A'

    type target, 'b'
    assert.equal input.getValue(), 'aA'

  test 'Should watch wzk.ui.form.Input', ->
    target = new wzk.ui.form.Input dom: dom
    target.render doc.body

    input = new MirrorInput dom: dom, target: target
    input.render doc.body

    type target.getElement(), 'a'
    assert.equal input.getValue(), target.getValue()

    type target.getElement(), 'b'
    assert.equal input.getValue(), target.getValue()

  test 'Should apply a filter on a value', ->
    input = new MirrorInput dom: dom, target: target
    input.addFilter (val) ->
      val.toUpperCase()
    input.addFilter (val) ->
      val.replace /\ /g, '_'
    input.render doc.body

    type target, 'a'
    assert.equal input.getValue(), 'A'

    type target, ' '
    assert.equal input.getValue(), 'A_'
