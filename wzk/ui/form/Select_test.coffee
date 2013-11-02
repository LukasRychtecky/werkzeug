suite 'wzk.ui.form.Select', ->

  select = null

  setup ->
    select = new wzk.ui.form.Select()

  test 'Should set value as a string', ->
    select.setValue 3
    assert.isString select.getValue()
