suite 'wzk.ui.form.ErrorMessageRenderer', ->
  renderer = wzk.ui.form.ErrorMessageRenderer.getInstance()
  component = null
  dom = null
  classes = ['foo', 'bar']

  mockDom = ->
    createDom: (tag, classes) ->
      mockEl tag, classes

  mockEl = (tag, classes) ->
    tag: tag
    classes: classes

  mockComponent = (classes) ->
    cssClasses: classes
    getDomHelper: ->
      dom

  setup ->
    dom = mockDom()

  test 'Should render errors as a UL with classes', ->
    component = mockComponent classes
    el = renderer.createDom component
    assert.equal el.tag, 'ul'
    assert.equal el.classes, 'error-list foo bar'
