suite 'wzk.resource.Query', ->
  Query = wzk.resource.Query

  query = null
  path = null

  setup ->
    path = '/user/api'
    query = new Query path

  test 'Should return a path with filters', ->
    query.filter 'first_name__contains', 'aster'
    query.filter 'role', '1'
    assert.equal query.composePath(), "#{path}?first_name__contains=aster&role=1"

  test 'Should contains a filter', ->
    query.filter 'role', '1'
    assert.isTrue query.hasFilter 'role'

  test 'Should have no filters', ->
    assert.isFalse query.hasFilter 'role'

  test 'Should not contains a filter', ->
    query.filter 'role', '1'
    assert.isFalse query.hasFilter 'first_name__contains'

  test 'Should remove a filter, an empty value', ->
    query.filter 'role', '1'
    assert.isTrue query.hasFilter 'role'

    query.filter 'role', undefined
    assert.isFalse query.hasFilter 'role'

  test 'Should be up to date, the value is empty', ->
    par = 'role'
    val = undefined
    assert.isFalse query.isChanged par, val

  test 'Should be up to date, the value has not been changed still undefined', ->
    par = 'role'
    val = undefined
    query.filter par, val
    assert.isFalse query.isChanged par, val

  test 'Should be up to date, the value has not been changed', ->
    par = 'role'
    val = 'ast'
    query.filter par, val
    assert.isFalse query.isChanged par, val

  test 'Should be up to date, the value is empty and an actual is undefined', ->
    assert.isFalse query.isChanged 'role', ''

  test 'Should not be up to date', ->
    par = 'first_name__contains'
    val = 'aster'
    assert.isTrue query.isChanged par, val

  test 'Should not be up to date, teh value has been changed', ->
    par = 'first_name__contains'
    val = 'aste'
    query.filter par, 'aster'
    assert.isTrue query.isChanged par, val

  test 'Should not be up to date, the value has been removed', ->
    par = 'first_name__contains'
    val = 'aster'
    query.filter par, val
    query.filter par, 'aste'
    assert.isTrue query.isChanged par, undefined
