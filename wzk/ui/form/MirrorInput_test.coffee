suite 'wzk.ui.form.MirrorInput', ->
  MirrorInput = wzk.ui.form.MirrorInput

  input = null
  target = null
  elements = null

  mockDom = (els) ->
    createDom: (tagName) ->
      els[tagName]

  mockEl = ->
    el =
      events: {}
      addEventListener: (type, listener) ->
        el.events[type] = listener
      value: ''
      insertBefore: ->
    el

  mockInput = ->
    el = mockEl()
    el.type = 'input'
    el

  renderInput = (input) ->
    input.createDom()
    input.enterDocument()

  type = (el, val) ->
    el.value += val
    el.events['keypress']?()

  setup ->
    elements =
      input: mockInput()

  test 'Should watch an element', ->
    target = mockInput()
    input = new MirrorInput dom: mockDom(elements), target: target
    renderInput input

    type target, 'a'
    assert.equal input.getValue(), target.value

    type target, 'b'
    assert.equal input.getValue(), target.value

  test 'Should stop watching after its value has been changed', ->
    target = mockInput()
    input = new MirrorInput dom: mockDom(elements), target: target
    renderInput input

    type target, 'a'
    assert.equal input.getValue(), target.value

    type input.getElement(), 'A'

    type target, 'b'
    assert.equal input.getValue(), 'aA'

  test 'Should watch wzk.ui.form.Input', ->
    target = new wzk.ui.form.Input dom: mockDom(elements)
    renderInput target
    input = new MirrorInput dom: mockDom(elements), target: target
    renderInput input

    type target.getElement(), 'a'
    assert.equal input.getValue(), target.getValue()

    type target.getElement(), 'b'
    assert.equal input.getValue(), target.getValue()

  test 'Should apply a filter on a value', ->
    target = mockInput()
    input = new MirrorInput dom: mockDom(elements), target: target
    input.addFilter (val) ->
      val.toUpperCase()
    input.addFilter (val) ->
      val.replace /\ /g, '_'
    renderInput input

    type target, 'a'
    assert.equal input.getValue(), 'A'

    type target, ' '
    assert.equal input.getValue(), 'A_'
