suite 'wzk.ui.inlineform.RowBuilder', ->
  E = wzk.ui.inlineform.RowBuilder.EventType

  builder = null
  row = null
  expert = null
  dom = null
  parent = null
  checkbox = null

  mockDom = ->
    getParentElement: ->
      parent

  mockParent = ->
    par =
      children: []
      appendChild: (el) ->
        par.children.push(el)
    par

  mockEl = (tag, className = '') ->
    el =
      className: className
      appendChild: ->
      tagName: tag
    el

  mockInput = (val) ->
    input = mockEl('input')
    input.value = val
    input

  mockRow = ->
    row = mockEl('tr', 'odd')
    row.querySelectorAll = ->
      [mockInput('foo')]
    row.querySelector = ->
      checkbox
    row.cloneNode = ->
      mockRow()
    row

  mockCheckbox = ->
    el = mockEl 'input'
    el.events = {}
    el.attachEvent = (type, clb) ->
      el.events[type] = clb
    el

  fireCheckboxClick = ->
    checkbox.events['onclick'](type: 'click', target: row)

  fireCheckboxSpaceKeyup = ->
    checkbox.events['onkeyup'](keyCode: goog.events.KeyCodes.SPACE, target: row)

  setup ->
    parent = mockParent()
    dom = mockDom()
    row = mockRow()
    checkbox = mockCheckbox()
    expert = new wzk.ui.inlineform.FieldExpert(1)
    builder = new wzk.ui.inlineform.RowBuilder(row, expert, dom)

  test 'Should add a row', ->
    builder.addRow()
    assert.equal parent.children.length, 1

  test 'Should fire a delete event on click', (done) ->
    goog.events.listen builder, E.DELETE, (e) ->
      done() if e.target is row

    builder.addRow()

    fireCheckboxClick()

  test 'Should fire a delete event on a space keyup', (done) ->
    goog.events.listen builder, E.DELETE, (e) ->
      done() if e.target is row

    builder.addRow()

    fireCheckboxSpaceKeyup()
