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
