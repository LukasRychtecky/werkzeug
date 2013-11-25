suite 'wzk.ui.form.Field', ->

  mockDom = ->
    {}

  test 'An error message should not be a child of a field', ->
    field = new wzk.ui.form.Field dom: mockDom()

    assert.equal field.getChildCount(), 0
