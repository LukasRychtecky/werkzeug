suite 'wzk.ui.Input', ->
  Input = wzk.ui.Input

  input = null
  dom = null
  parent = null
  doc = null

  setup ->
    doc = jsdom("""
    <html><head></head>
    <body>
    </body>
    </html>
    """)
    parent = doc.body
    dom = new wzk.dom.Dom doc

  suite '#render', ->

    test 'Should render a basic input', ->
      input = new Input(null, wzk.ui.InputRenderer.getInstance(), dom)
      input.render parent
      assert.equal parent.children.length, 1

    test 'Should render a search input', ->
      input = new Input(null, wzk.ui.InputSearchRenderer.getInstance(), dom)
      input.render parent
      assert.equal parent.children[0].children.length, 2

  suite '#makeRequired', ->

    setup ->
      input = new Input(null, wzk.ui.InputRenderer.getInstance(), dom)
      input.render parent

    test 'Should make an input required', ->
      input.makeRequired()
      assert.equal input.getElement().required, 'required'

    test 'Should make an input non required', ->
      input.makeRequired(false)
      assert.isUndefined input.getElement().required
