suite 'wzk.num', ->

  assertNan = (actual) ->
    assert.equal actual.toString(), 'NaN'

  suite '#parseDec', ->

    test 'Should be a number', ->
      assert.equal wzk.num.parseDec('10'), 10

    test 'Should return an implicit value', ->
      impl = 20
      assert.equal wzk.num.parseDec('asdf', impl), impl

    test 'Should return NaN', ->
      assertNan wzk.num.parseDec('asdf')
