suite 'wzk.ui.Component', ->

  test 'Should have a default renderer', ->
    assert.instanceOf new wzk.ui.Component().renderer, wzk.ui.ComponentRenderer
