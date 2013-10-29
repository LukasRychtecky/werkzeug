suite 'wzk.ui.form.QuasiFormRenderer', ->
  renderer = wzk.ui.form.QuasiFormRenderer.getInstance()
  form = null
  dom = null

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

  mockForm = ->
    getDomHelper: ->
      dom
    forEachChild: ->

  setup ->
    dom = mockDom()
    form = mockForm()

  test 'Should render a legend', ->
    legend = 'Legend'
    form.legend = legend
    renderer.createDom form
    assert.equal dom.tags[1].txt, legend

  test 'Should not render a legend', ->
    renderer.createDom form
    assert.equal dom.tags.length, 1
