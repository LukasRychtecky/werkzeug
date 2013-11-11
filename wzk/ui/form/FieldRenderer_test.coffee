suite 'wzk.ui.form.FieldRenderer', ->
  renderer = null
  dom = null
  comp = null

  mockEl = (tag, attrs = {}) ->
    el =
      children: []
      tagName: tag
      appendChild: (child) ->
        el.children.push child
    el[attr] = val for attr, val of attrs
    el

  mockDom = ->
    createDom: (tag, attrs) ->
      mockEl tag, attrs

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
    dom = mockDom()
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
