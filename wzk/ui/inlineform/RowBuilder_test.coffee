suite 'wzk.ui.inlineform.RowBuilder', ->
  E = wzk.ui.inlineform.RowBuilder.EventType

  builder = null
  row = null
  expert = null
  dom = null
  parent = null
  checkbox = null

  mockDom = ->
    getParentElement: -> parent
    lastChildOfType: -> {}
    one: -> checkbox
    el: (tag) ->
      mockEl tag
    insertSiblingAfter: (newNode, refNode) ->
      refNode.nextSibling = newNode
    all: -> []

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
      style: {}
      children: []
      insertBefore: (newEl, before) ->
        @children.push newEl
      attachEvent: (type, clb) ->
        @events[type] = clb
      events: {}
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
    el.parentNode = mockEl 'td'
    el.parentNode.insertBefore = (node) ->
      el.nextSibling = node
    el

  fireCheckboxClick = ->
    checkbox.nextSibling.events['onclick'](type: 'click', target: row)

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
