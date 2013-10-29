suite 'wzk.ui.ComponentRenderer', ->
  renderer = wzk.ui.ComponentRenderer.getInstance()
  component = null

  mockComponent = (classes...) ->
    cssClasses: classes

  test 'Should return classes as a string', ->
    component = mockComponent('foo', 'bar')
    assert.equal renderer.getClassesAsString(component), 'foo bar'
