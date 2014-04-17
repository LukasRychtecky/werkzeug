suite 'wzk.fx.HandlebarRenderer', ->
  renderer = null
  doc = null
  dom = null
  comp = null

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    </body>
    </html>
    """
    renderer = wzk.fx.HandlebarRenderer.getInstance()
    dom = new wzk.dom.Dom doc
    comp = new wzk.ui.Component dom: dom

  test 'Should create an element with a class', ->
    klass = 'klass'
    comp.addClass klass
    el = renderer.createDom comp
    assert.equal el.className, 'klass'

  test 'Should create an element with tag name DIV', ->
    assert.equal renderer.createDom(comp).tagName.toLowerCase(), 'div'

  test 'Should has a handle icon', ->
    assert.equal renderer.createDom(comp).children[0].tagName.toLowerCase(), 'span'
