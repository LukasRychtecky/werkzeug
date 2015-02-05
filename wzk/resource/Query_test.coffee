suite 'wzk.resource.Query', ->
  Query = wzk.resource.Query
  FV = wzk.resource.FilterValue

  query = null
  path = null

  setup ->
    path = '/user/api'
    query = new Query path

  test 'Should compose a GET request without parameters', ->
    query = new Query "#{path}?first_name__contains=aster&role=1"
    assert.equal query.composeGet(1), "#{path}/1"

  test 'Should return a path with filters', ->
    query.filter new FV('first_name__contains', '', 'aster')
    query.filter new FV('role', '', '1')
    assert.equal query.composePath(), "#{path}?first_name__contains=aster&role=1"

  test 'Should contains a filter', ->
    query.filter new FV('role', '', '1')
    assert.isTrue query.hasFilter 'role'

  test 'Should have no filters', ->
    assert.isFalse query.hasFilter 'role'

  test 'Should not contains a filter', ->
    query.filter new FV('role', '', '1')
    assert.isFalse query.hasFilter 'first_name__contains'

  test 'Should remove a filter, an empty value', ->
    query.filter new FV('role', '', '1')
    assert.isTrue query.hasFilter 'role'

    query.filter new FV('role', '', undefined)
    assert.isFalse query.hasFilter 'role'

  test 'Should be up to date, the value is empty', ->
    assert.isFalse query.isChanged new FV('role', '', undefined)

  test 'Should be up to date, the value has not been changed still undefined', ->
    filter = new FV('role', '', undefined)
    query.filter filter
    assert.isFalse query.isChanged filter

  test 'Should be up to date, the value has not been changed', ->
    filter = new FV('role', '', 'ast')
    query.filter filter
    assert.isFalse query.isChanged filter

  test 'Should be up to date, the value is empty and an actual is undefined', ->
    assert.isFalse query.isChanged new FV('role', '', '')

  test 'Should not be up to date', ->
    assert.isTrue query.isChanged new FV('first_name', 'contains', 'aster')

  test 'Should not be up to date, the value has been changed', ->
    filter = new FV('first_name', 'contains', 'aster')
    query.filter filter
    assert.isTrue query.isChanged new FV('first_name', 'contains', 'aste')

  test 'Should not be up to date, the value has been removed', ->
    query.filter new FV('first_name', 'contains', 'aster')
    query.filter new FV('first_name', 'contains', 'aste')
    assert.isTrue query.isChanged new FV('first_name', 'contains', undefined)
