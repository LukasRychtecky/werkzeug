suite 'wzk.ui.Component', ->

  component = null
  parent = null
  sibling = null

  class ExtComp extends wzk.ui.Component

    constructor: (params, @done) ->
      super params

    afterRendering: ->
      @done()

  class BeforeRendering extends wzk.ui.Component

    constructor: (params, @done) ->
      super params
      @count = 0

    beforeRendering: ->
      @done() if @count is 0

    afterRendering: ->
      @count++

  buildComp = (done) ->
    component = new ExtComp {}, done

  buildbeforeRenderingComp = (done) ->
    component = new BeforeRendering {}, done

  setup ->
    component = new wzk.ui.Component()
    parent =
      insertBefore: ->
    sibling =
      parentNode: parent

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

    test 'Should insert a component as a child', (done) ->
      parent.insertBefore = ->
        done()
      component.render parent

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).render parent

  suite '#renderBefore', ->

    mockParent = (done = ->) ->
      parent.insertBefore = (el, sib) ->
        done() if sib is sibling

    test 'Should insert a component before an element', (done) ->
      mockParent done
      component.renderBefore sibling

    test 'Should call a callback after rendering', (done) ->
      mockParent()
      buildComp(done).renderBefore sibling

    test 'Should call a callback before rendering', (done) ->
      mockParent()
      buildbeforeRenderingComp(done).renderBefore sibling

  suite '#renderAfter', ->

    nextSib = null

    setup ->
      nextSib = {}
      sibling.nextSibling = nextSib

    test 'Should insert a component after an element', (done) ->
      parent.insertBefore = (el, sib) ->
        done() if sib is nextSib

      component.renderAfter sibling

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).renderAfter sibling

  suite '#enterDocument', ->

    test 'Should call a callback after rendering', (done) ->
      buildComp(done).enterDocument()

  suite '#createDom', ->

    mockChild = (done) ->
      getParent: ->
      getId: ->
        ''
      setParent: ->
      render: ->
        done()

    test 'Should render also children', (done) ->
      comp = buildComp()
      comp.addChild mockChild(done)
      comp.createDom()
