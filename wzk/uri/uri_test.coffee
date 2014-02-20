suite 'wzk.uri', ->
  suite '#queryParser', ->

    test 'Parses hash query parameters into array', ->
      assert.equal wzk.uri.getFragmentParam('key1', '#key1=val1&key2=val2'), 'val1'
      assert.equal wzk.uri.getFragmentParam('key2', '#key1=val1&key2=val2'), 'val2'

    test 'Adding parametr to empty query', ->
      assert.equal wzk.uri.addFragmentParam('key2', 'val2'), 'key2=val2'
