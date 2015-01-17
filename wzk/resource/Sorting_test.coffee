suite 'wzk.resource.Sorting', ->
  Sorting = wzk.resource.Sorting

  sorting = null

  setup ->
    sorting = new Sorting()

  test 'Should sort by defauls' , ->
    assert.equal sorting.toString(), ''

  test 'Should sort by name asc.', ->
    sorting.asc('name')
    assert.equal sorting.toString(), 'name'

  test 'Should sort by name asc., age desc.', ->
    sorting.asc('name')
    sorting.desc('age')
    assert.equal sorting.toString(), 'name,-age'

  test 'Should only sort by age desc.', ->
    sorting.asc('name')
    sorting.desc('age')
    sorting.remove('name')
    assert.equal sorting.toString(), '-age'
