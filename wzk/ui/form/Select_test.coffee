suite 'wzk.ui.form.Select', ->

  select = null
  opts = null
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
    opts =
      bar1: 'foo1'
      bar2: 'foo2'
      3: '3a'
    select = new wzk.ui.form.Select dom: dom, options: opts

  test 'Should set value as a string', ->
    select.setValue 3
    assert.isString select.getValue()

  test 'Should select first option by default', ->
    selected = select.getValue()
    assert.isTrue selected.length > 0

  test 'Should select first option after setting new options', ->
    select = new wzk.ui.form.Select dom: dom
    select.setOptions foo: 'bar'
    assert.equal select.getValue(), 'foo'

  test 'Should select an option with a current value', ->
    select = new wzk.ui.form.Select value: 2, dom: dom
    select.setOptions
      "1": 1
      "2": 2
    assert.equal select.getValue(), "2"
