suite 'wzk.ui.Input', ->
  Input = wzk.ui.Input

  input = null
  dom = null
  parent = null
  doc = null
  el = null

  mockDom = (children = null) ->
    dom =
      el: (tag) ->
        mockEl(tag.toUpperCase())
      getDocument: ->
        doc
      getChildren: ->
        assert.fail 'getChildren should not be called!' unless children?
        children
    dom

  mockDoc = ->
    {}

  mockEl = (tag) ->
    el =
      appendChild: ->
      insertBefore: ->
      ownerDocument: doc
      getAttributeNode: ->
      attachEvent: ->
      tagName: tag
      required: undefined
    el

  setup ->
    doc = mockDoc()
    parent = mockEl('div')

  suite '#render', ->

    test 'Should render a basic input', ->
      dom = mockDom()
      input = new Input(null, wzk.ui.InputRenderer.getInstance(), dom)
      input.render(parent)

    test 'Should render a search input', ->
      dom = mockDom([mockEl()])
      input = new Input(null, wzk.ui.InputSearchRenderer.getInstance(), dom)
      input.render(parent)

  suite '#makeRequired', ->

    setup ->
      dom = mockDom()
      input = new Input(null, wzk.ui.InputRenderer.getInstance(), dom)
      input.render(parent)

    test 'Should make an input required', ->
      input.makeRequired()
      assert.equal input.getElement().required, 'required'

    test 'Should make an input non required', ->
      input.makeRequired(false)
      assert.isUndefined input.getElement().required
