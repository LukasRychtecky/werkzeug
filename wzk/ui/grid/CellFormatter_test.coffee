suite 'wzk.ui.grid.CellFormatter', ->
  CellFormatter = wzk.ui.grid.CellFormatter

  formatter = null
  model = null

  setup ->
    formatter = new CellFormatter()
    json =
      contacts: [
        {_obj_name: 'Foo'},
        {_obj_name: 'Bar'}
      ],
      owned_by:
        state: 'Waiting for approval'
      main:
        contacts: [
          {_obj_name: 'Foo'},
          {_obj_name: 'Bar'}
        ]
    model = new wzk.resource.ModelBuilder().build json

  test 'Should concat value items', ->
    actual = formatter.format model, 'contacts'
    assert.equal actual, 'Foo, Bar'

  test 'Should return deep value', ->
    actual = formatter.format model, 'owned_by__state'
    assert.equal model.owned_by.state, actual

  test 'Should concat deep value', ->
    actual = formatter.format model, 'main__contacts'
    assert.equal 'Foo, Bar', actual
