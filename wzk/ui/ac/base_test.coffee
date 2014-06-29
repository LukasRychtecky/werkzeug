suite 'wzk.ui.ac', ->

  dom = null
  doc = null
  select = null
  features =
    features:
      "QuerySelector": true

  checkComponentButtons = ->
    assert.isNotNull dom.cls klass for klass in ['close', 'open-list']

  hasCloseIcon = (parent = '') ->
    if parent isnt ''
      parent += ' '
    icon = dom.one(parent + '.goog-icon-remove')
    return false if icon? and icon.style.display? and icon.style.display is 'none'
    icon isnt null

  buildDOM = (multiple, readonly = false) ->
    doc = jsdom("""
      <html><head></head>
      <body>
        <select#{if multiple then ' multiple' else ''}#{if readonly then ' readonly' else ''}>
          <option value="0">a</option>
          <option value="1">b</option>
          <option value="2" selected>c</option>
          <option value="4">d</option>
        </select>
      </body>
      </html>
      """, null, features)

    dom = new wzk.dom.Dom doc
    select = dom.one 'select'

  test 'Should decorate a native select', ->
    buildDOM false
    wzk.ui.ac.buildSelectAutoCompleteNative select, dom

    assert.isFalse goog.style.isElementShown select
    checkComponentButtons()

  test 'Should throw an error because an invalid select to decorate', ->
    buildDOM true
    try
      wzk.ui.ac.buildSelectAutoCompleteNative select, dom
      assert.fail 'should throw an error'
    catch e
      assert.match e.message, /For select/

  test 'Should throw an error because an invalid select to decorate', ->
    buildDOM false
    try
      wzk.ui.ac.buildExtSelectboxFromSelectNative select, dom
      assert.fail 'should throw an error'
    catch e
      assert.match e.message, /For select/

  test 'Should decorate a native multiple select', ->
    buildDOM true
    wzk.ui.ac.buildExtSelectboxFromSelectNative select, dom

    assert.isFalse goog.style.isElementShown select
    checkComponentButtons()

  test 'SelectAutoComplete should not be readonly', ->
    buildDOM false, false
    wzk.ui.ac.buildSelectAutoCompleteNative select, dom

    assert.isTrue hasCloseIcon()

  test 'SelectAutoComplete should be readonly', ->
    buildDOM false, true
    wzk.ui.ac.buildSelectAutoCompleteNative select, dom

    assert.isFalse hasCloseIcon()

  test 'ExtSelectbox should not be readonly', ->
    buildDOM true, false
    wzk.ui.ac.buildExtSelectboxFromSelectNative select, dom

    assert.isTrue hasCloseIcon('.tag-container')

  test 'ExtSelectbox should be readonly', ->
    buildDOM true, true
    wzk.ui.ac.buildExtSelectboxFromSelectNative select, dom

    assert.isFalse hasCloseIcon('.tag-container')
