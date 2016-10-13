suite 'wzk.dom.Dom', ->

  dom = null
  doc = null

  setup ->
    doc = jsdom '<html><head></head><body></body></html>'
    dom = new wzk.dom.Dom doc
    doc.body.innerHTML = ''


  suite '#el', ->

    test 'Should set a text content to the new element', ->
      doc.body.textContent = 'novy'
      txt = 'Text content'
      el = dom.el('div', {}, txt)
      assert.equal el.textContent, txt

    test 'Should append the new element as a child', ->
      dom.el 'div', {}, doc.body
      assert.equal doc.body.children.length, 1

    test 'Should omit a third argument', ->
      el = dom.el('div', {}, {})
      assert.equal el.children.length, 0


  suite '#isNode', ->

    test 'Should be a Node', ->
      assert.isTrue dom.isNode(doc.body)

    test 'Should not be a Node', ->
      assert.isFalse dom.isNode(null)

  suite '#elements', ->

    test 'Should create divs', ->
      div = dom.div('div-cls',
        dom.div('child-1'),
        dom.div('child-2'),
        dom.div('child-3')
      )

      doc.body.appendChild div

      assert.isTrue dom.isNode(div)
      assert.equal div.children.length, 3

      for child, i in div.children
        assert.equal child.tagName, 'DIV'
        assert.isTrue dom.isNode(child)
        assert.equal child.className, "child-#{i + 1}"

  suite '#cx', ->

    test 'Should create classes list', ->
      result = 'a b c'

      cx = dom.cx({
        'a': true
        'ne': false
        'ne': false
        'b': true
        'c': true
        'ne': false
      })

      assert.equal cx, result

  suite '#getFirstSibling, #getLastSibling', ->

    html = """
    <html><head></head>
    <body>
    <div class="first"></div>
    <div class="mid"></div>
    <div class="last"></div>
    </body>
    </html>
    """

    setup ->
      doc = jsdom html

    test 'Should return first sibling', ->
      first = dom.getFirstSibling doc.body.children[1]
      assert.equal first.className, 'first'

    test 'First sibling should not exists', ->
      assert.isNull dom.getFirstSibling(doc.body.children[0])

    test 'Should return last sibling', ->
      last = dom.getLastSibling doc.body.children[1]
      assert.equal last.className, 'last'

    test 'Last sibling should not exists', ->
      assert.isNull dom.getLastSibling(doc.body.children[2])
