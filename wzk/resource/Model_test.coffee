suite 'wzk.resource.Model', ->
  Model = wzk.resource.Model

  data = null

  setup ->
    data =
      first_name: "Asterix",
      last_name: "Gaul",
      is_active: "Ano",
      id: "1",
      role: "Superuser",
      is_verified: "Ne",
      email: "asterix@rychmat.eu"

  test 'Should return _obj_name when converting into string', ->
    name = "asterix@rychmat.eu"
    data[Model.TO_S] = name
    model = new Model data
    assert.equal model.toString(), name

  test 'Should take any value if, there is no _obj_name attribute', ->
    model = new Model data
    assert.isDefined model
