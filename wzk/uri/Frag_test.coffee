suite 'wzk.uri.Frag', ->
  Frag = wzk.uri.Frag

  frag = null

  setup ->
    frag = new Frag '#g:b=20&g:i=1'

  test 'Should return proper values', ->
    assert.equal frag.getParam('g:b'), '20'
    assert.equal frag.getParam('g:i'), '1'

  test 'Should a canonized fragment', ->
    frag.setParam 'g:b', null
    frag.setParam 'b:d', '12'
    assert.equal frag.toString(), 'g%3Ai=1&b%3Ad=12'

  test 'Should return an empty frag', ->
    frag.removeParam 'g:b'
    frag.removeParam 'g:i'
    assert.equal frag.toString(), ''
