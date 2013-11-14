suite 'wzk.str', ->

  suite '#slugify', ->

    test 'Should slugify a German sentence', ->
      assert.equal wzk.str.slugify('Es ist ein großer Bertha'), 'es-ist-ein-grosser-bertha'

    test 'Should slugify a Czech sentence', ->
      assert.equal wzk.str.slugify('Příliš žluťoučký kůň úpěl ďábelské ódy.'), 'prilis-zlutoucky-kun-upel-dabelske-ody'

    test 'Should slugify a Frech sentence', ->
      assert.equal wzk.str.slugify("Un éléphant à l'orée du bois"), 'un-elephant-a-loree-du-bois'

    test 'Should return an empty string for an empty string', ->
      assert.equal wzk.str.slugify(''), ''

    test 'Should return an empty string for null', ->
      assert.equal wzk.str.slugify(null), ''

  suite '#asciify', ->

    test 'Should asciify a German sentence', ->
      assert.equal wzk.str.asciify('Es ist ein großer Bertha'), 'Es ist ein grosser Bertha'

  suite '#dasherize', ->

    test 'Should dasherize a German sentence', ->
      assert.equal wzk.str.dasherize('Es ist ein großer Bertha'), 'Es-ist-ein-großer-Bertha'

    test 'Should replace everything except a whitespace, a dash and a word char', ->
      assert.equal wzk.str.dasherize('" -_?a ', false), '--_a'

  suite '#alfanumeric', ->

    test 'Should return an alfanumeric string', ->
      assert.equal wzk.str.alfanumeric('a-3_?'), 'a3'
