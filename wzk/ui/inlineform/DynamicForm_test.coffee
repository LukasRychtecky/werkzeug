suite 'wzk.ui.inlineform.DynamicForm', ->
  dynamicForm = null
  dom = null
  fieldset = null
  btn = null
  parent = null
  config = null
  dataset = null
  form = null

  mockFieldset = (dataset, form) ->
    querySelector: (sel) ->
      dataset[sel]
    querySelectorAll: (sel) ->
      dataset[sel]
    form: form

  mockRow = ->
    row = mockEl('tr', 'odd')
    row.querySelectorAll = ->
      [mockInput('foo')]
    row.querySelector = ->
      mockCheckbox()
    row.cloneNode = ->
      mockRow()
    row

  mockInput = (val, name = '') ->
    input = mockEl('input')
    input.value = val
    input.name = name
    input

  mockCheckbox = ->
    checkbox = mockEl 'input'
    checkbox.type = 'checkbox'
    checkbox

  mockEl = (tag, className = '') ->
    el =
      className: className
      appendChild: ->
      tagName: tag
      events: {}
      attachEvent: (type, e) ->
        el.events[type] = e
      style: {}
    el

  fireClick = ->
    e = type: 'onclick'
    btn.events[e.type]({})

  mockDom = ->
    getParentElement: ->
      parent
    removeNode: ->

  mockForm = ->
    events: {}
    attachEvent: (type, clbk) ->
      @events[type] = clbk

  mockParent = ->
    par =
      children: []
      appendChild: (el) ->
        par.children.push(el)
    par

  setup ->
    parent = mockParent()
    dom = mockDom()
    btn = mockEl('button', 'dynamic')

    config = [
      mockInput(2, '__TOTAL_FORMS')
    ]

    dataset =
      'input[type=hidden]': config
      'table tbody tr:last-child': mockRow()
      '.dynamic': btn
      'table tbody tr': []

    form = mockForm()

    dynamicForm = new wzk.ui.inlineform.DynamicForm(dom)

  test 'Should make a dynamic form', ->
    config.push(mockInput(10, '__MAX_NUM_FORMS'))
    fieldset = mockFieldset(dataset, form)
    dynamicForm.dynamic(fieldset)

    fireClick()

    assert.equal parent.children.length, 1
    assert.isFunction form.events['onsubmit']

  test 'Should disable the button, a count of forms is limited by MAX_NUM_FORMS', ->
    config.push(mockInput(2, '__MAX_NUM_FORMS'))
    fieldset = mockFieldset(dataset, form)
    dynamicForm.dynamic(fieldset)

    fireClick()
    fireClick()

    assert.equal parent.children.length, 2
    assert.isFunction form.events['onsubmit']

  test 'A fieldset must contains an element with "dynamic" class', ->
    fieldset = mockFieldset('input[type=hidden]': [])
    try
      dynamicForm.dynamic(fieldset)
    catch err
      assert.instanceOf err, ReferenceError
