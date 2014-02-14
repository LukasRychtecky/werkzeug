suite 'wzk.ui.grid.CellFormatter', ->
  CellFormatter = wzk.ui.grid.CellFormatter

  formatter = null
  model = null

  setup ->
    formatter = new CellFormatter()
    model =
      contacts: [
        {_obj_name: 'Foo'},
        {_obj_name: 'Bar'}
      ]

  test 'Should concat value items', ->
    actual = formatter.format model.contacts
    assert.equal 'Foo, Bar', actual
