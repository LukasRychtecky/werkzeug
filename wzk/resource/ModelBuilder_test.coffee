suite 'wzk.resource.ModelBuilder', ->
  ModelBuilder = wzk.resource.ModelBuilder

  builder = null
  json = null
  arr = null

  setup ->
    builder = new ModelBuilder
    json =
      first_name: "Asterix",
      last_name: "Gaul",
      is_active: "Ano",
      id: "1",
      role: "Superuser",
      email: "asterix@rychmat.eu"

    arr = [json]

  test 'Should build a model from JSON', ->
    model = builder.build json
    assert.instanceOf model, wzk.resource.Model

  test 'Should build an array of models', ->
    actual = builder.build arr
    assert.isArray actual
    assert.instanceOf actual[0], wzk.resource.Model
