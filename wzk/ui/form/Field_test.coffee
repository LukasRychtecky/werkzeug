suite 'wzk.ui.form.Field', ->

  doc = null
  dom = null

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc

  test 'An error message should not be a child of a field', ->
    field = new wzk.ui.form.Field dom: dom

    assert.equal field.getChildCount(), 0

  test 'Should convert an object to JSON', ->
    obj =
      foo: 'bar'
    field = new wzk.ui.form.Field dom: dom, value: obj
    assert.equal field.getValue(), '{"foo":"bar"}'
