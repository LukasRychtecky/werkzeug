suite 'wzk.ui.form.FieldRenderer', ->
  renderer = null
  dom = null
  comp = null

  mockComponent = ->
    cssClasses: []
    createDom: ->
      renderer.createDom @
    getDomHelper: ->
      dom
    getId: ->
      ''

  setup ->
    renderer = wzk.ui.form.FieldRenderer.getInstance()
    doc = jsdom """
    <html><head></head>
    <body>
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc
    comp = mockComponent()

  test 'Should render a placeholder attribute', ->
    placeholder = 'Foo'
    comp.placeholder = placeholder
    el = renderer.createDom comp
    assert.equal el.placeholder, placeholder

  test 'Should not render a placeholder attribute', ->
    el = renderer.createDom comp
    assert.isUndefined el.placeholder

  test 'Should render a required attribute', ->
    comp.required = true
    el = renderer.createDom comp
    assert.equal el.required, 'required'

  test 'Should not render a required attribute', ->
    comp.required = false
    el = renderer.createDom comp
    assert.isUndefined el.required
