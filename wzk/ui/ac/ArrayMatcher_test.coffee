suite 'wzk.ui.ac.ArrayMatcher', ->

  matcher = null
  rows = []

  setup ->
    rows = ['aa', 'ab']
    matcher = new wzk.ui.ac.ArrayMatcher rows

  test 'Should call a match handler on an empty token', (done) ->
    handler = (token, matched) ->
      assert.equal matched.length, rows.length
      done()

    matcher.requestMatchingRows '', 20, handler

  test 'Should not call a match handler on an empty token', (done) ->
    handler = (matched) ->
      assert.equal matched.length, 0
      done()

    matcher.showAllOnEmpty = false
    matcher.requestMatchingRows '', 20, handler
