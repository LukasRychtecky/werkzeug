suite 'wzk.ui.Component', ->

  doc = null
  component = null
  parent = null
  dom = null
  last = null
  first = null
  parentChildCount = 0

  class ExtComp extends wzk.ui.Component

    constructor: (params, @done) ->
      super params

    afterRendering: ->
      @done() if @done?

  class BeforeRendering extends wzk.ui.Component

    constructor: (params, @done) ->
      super params
      @count = 0

    beforeRendering: ->
      @done() if @count is 0

    afterRendering: ->
      @count++

  buildComp = (done = null) ->
    component = new ExtComp {dom: dom}, done

  buildBeforeRenderingComp = (done) ->
    component = new BeforeRendering {dom: dom}, done

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    <div class="first"></div>
    <div class="last"></div>
    </body>
    </html>"""
    dom = new wzk.dom.Dom doc
    component = new wzk.ui.Component dom: dom
    parent = doc.body
    first = doc.body.children[0]
    last = doc.body.children[1]
    parentChildCount = parent.children.length

  suite '#render', ->

    test 'Should have a default renderer', ->
      assert.instanceOf component.renderer, wzk.ui.ComponentRenderer

    test 'Should throw an exception, the component is already rendered', ->
      component.enterDocument()
      try
        component.render(parent)
        assert.fail()
      catch err
        assert.instanceOf err, Error

    test 'Should insert a component as a child', ->
      component.render parent
      assert.equal parent.children.length, parentChildCount + 1

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).render parent

    test 'Should render children', ->
      comp = buildComp()
      comp.addChild buildComp()
      comp.render parent
      assert.equal comp.getChildCount(), 1

    test 'Should not render children', ->
      comp = buildComp()
      comp.renderChildrenInternally = false
      nothing = ->
      comp.addChild buildComp()
      comp.render parent
      assert.equal comp.getChildCount(), 1
      assert.equal comp.getElement().children.length, 0


  suite '#renderBefore', ->

    test 'Should insert a component before an element', ->
      component.renderBefore last
      assert.equal doc.body.children[1], component.getElement()

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).renderBefore last

    test 'Should call a callback before rendering', (done) ->
      buildBeforeRenderingComp(done).renderBefore last


  suite '#renderAfter', ->

    test 'Should insert a component after an element', ->
      component.renderAfter first
      assert.equal parent.children[1], component.getElement()

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).renderAfter first


  suite '#enterDocument', ->

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).enterDocument()


  suite '#createDom', ->

    test 'Should render also children', ->
      comp = buildComp()
      comp.addChild buildComp()
      comp.createDom()
      assert.equal comp.getElement().children.length, 1

    test 'Should not create an element if a component is in DOM', ->
      component.render parent
      component.setElementInternal = ->
        assert.fail 'Element should not be build again'
      component.createDom()

    test 'Should not create children elements', ->
      comp = buildComp()
      comp.renderChildrenInternally = false
      comp.addChild buildComp()
      comp.createDom()
      assert.equal comp.getElement().innerHTML, ''


  suite '#destroy', ->

    test 'Should destroy a component', ->
      comp = buildComp()
      comp.render last
      assert.equal last.children.length, 1
      comp.destroy()
      assert.equal last.children.length, 0
