suite 'wzk.dom.Dom', ->

  dom = null
  doc = null

  mockTextNode = (txt) ->
    txt: txt

  mockEl = (tag) ->
    el = document.createElement(tag)
    el.children = []
    el.ownerDocument = doc
    el.appendChild = (child) ->
      el.children.push(child)

    el

  mockDocument = ->
    createTextNode: (txt) ->
      mockTextNode(txt)
    createElement: (tag) ->
      mockEl(tag)

  setup ->
    doc = mockDocument()
    dom = new wzk.dom.Dom(doc)


  suite '#el', ->

    test 'Should set a text content to the new element', ->
      txt = 'Text content'
      el = dom.el('div', {}, txt)
      assert.equal el.children[0].txt, txt

    test 'Should append the new element as a child', ->
      parent = mockEl('div')
      dom.el('div', {}, parent)
      assert.equal parent.children.length, 1

    test 'Should omit a third argument', ->
      el = dom.el('div', {}, {})
      assert.equal el.children.length, 0


  suite '#isNode', ->

    test 'Should be a Node', ->
      assert.isTrue dom.isNode(nodeType: 1)

    test 'Should not be a Node', ->
      assert.isFalse dom.isNode(null)
