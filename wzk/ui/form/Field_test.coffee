suite 'wzk.ui.form.Field', ->

  mockDom = ->
    {}

  test 'An error message should not be a child of a field', ->
    field = new wzk.ui.form.Field dom: mockDom()

    assert.equal field.getChildCount(), 0

  test 'Should convert an object to JSON', ->
    obj =
      foo: 'bar'
    field = new wzk.ui.form.Field dom: mockDom(), value: obj
    assert.equal field.getValue(), '{"foo":"bar"}'
