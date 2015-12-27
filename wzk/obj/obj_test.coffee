suite 'wzk.obj', ->

  suite '#merge', ->

    test 'Should merge two object into first one', ->
      obj1 =
        a: 1
        b: 2
      obj2 =
        a: -1
        c: 3

      expected =
        a: 1
        b: 2
        c: 3

      wzk.obj.merge obj1, obj2
      assert.deepEqual expected, obj1

  suite '#dict', ->

    test 'Should creates an empty dictionary', ->
      assert.deepEqual({}, wzk.obj.dict([], ->))

    test 'Should creates a dictionary', ->
      assert.deepEqual({'0': 0, '1': 1, '2': 2}, wzk.obj.dict([0, 1, 2], (item, i) -> [String(i), i]))
