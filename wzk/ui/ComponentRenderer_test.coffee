suite 'wzk.ui.ComponentRenderer', ->
  renderer = wzk.ui.ComponentRenderer.getInstance()
  component = null
  dom = null

  mockComponent = ->
    cssClasses: []
    addClass: (klass) ->
      @cssClasses.push klass

  setup ->
    dom = new wzk.dom.Dom document

  test 'Should return classes as a string', ->
    component = mockComponent()
    component.addClass 'foo'
    component.addClass 'bar'
    assert.equal renderer.getClassesAsString(component), 'foo bar'
