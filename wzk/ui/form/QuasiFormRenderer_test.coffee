suite 'wzk.ui.form.QuasiFormRenderer', ->
  renderer = wzk.ui.form.QuasiFormRenderer.getInstance()
  form = null
  dom = null
  legend = 'Legend'

  mockDom = ->
    d =
      tags: []
      createDom: (tag, attrs, txt) ->
        el = mockEl(tag, txt)
        d.tags.push el
        el
    d

  mockEl = (tag, txt) ->
    tag: tag
    txt: txt
    appendChild: ->

  mockForm = (helper) ->
    getDomHelper: ->
      helper
    forEachChild: ->
    getId: ->
      ''

  setup ->
    dom = mockDom()
    form = mockForm dom

  test 'Should render a legend', ->
    form.legend = legend
    renderer.createDom form
    assert.equal dom.tags[1].txt, legend

  test 'Should not render a legend', ->
    renderer.createDom form
    assert.equal dom.tags.length, 1

  test 'Should create a legend without fieldset', ->
    fieldset =
      appendChild: ->
    form.legend = legend
    renderer.createFieldsetChildren form, fieldset
    assert.equal dom.tags.length, 1
    assert.equal dom.tags[0].tag, 'legend'
