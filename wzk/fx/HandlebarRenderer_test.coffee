suite 'wzk.fx.HandlebarRenderer', ->
  renderer = null
  dom = null
  comp = null

  mockEl = (tag, attrs = {}) ->
    el =
      children: []
      tagName: tag
      appendChild: (child) ->
        el.children.push child
    el[attr] = val for attr, val of attrs
    el

  mockDom = ->
    createDom: (tag, attrs) ->
      mockEl tag, attrs

  mockComponent = ->
    cssClasses: []
    createDom: ->
      renderer.createDom @
    getDomHelper: ->
      dom
    getId: ->
      ''

  setup ->
    renderer = wzk.fx.HandlebarRenderer.getInstance()
    dom = mockDom()
    comp = mockComponent()

  test 'Should create an element with a class', ->
    klass = 'klass'
    comp.cssClasses.push klass
    el = renderer.createDom(comp)
    assert.equal el['class'], 'klass'

  test 'Should create an element with tag name DIV', ->
    assert.equal renderer.createDom(comp).tagName, 'div'

  test 'Should has a handle icon', ->
    assert.equal renderer.createDom(comp).children[0].tagName, 'span'
