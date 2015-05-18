suite 'wzk.ui.inlineform.DynamicForm', ->
  form = null
  dom = null
  fieldset = null
  btn = null
  parent = null
  doc = null

  fireClick = ->
    btn._listeners['click'].false[0].listener.listener({})

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
    <fieldset>
      <input id="id_external-inline-file-TOTAL_FORMS" name="external-inline-file-TOTAL_FORMS" type="hidden" value="0">
      <input id="id_external-inline-file-INITIAL_FORMS" name="external-inline-file-INITIAL_FORMS" type="hidden" value="0">
      <input id="id_external-inline-file-MAX_NUM_FORMS" name="external-inline-file-MAX_NUM_FORMS" type="hidden" value="2">
      <table class="form">
        <thead>
        <tr class="inline-header">
          <th>File</th>
          <th>Delete</th>
        </tr>
        </thead>
        <tbody>
        <tr class="odd inline-line">
          <td class="field">
            <input id="id_external-inline-file-__prefix__-message" name="external-inline-file-__prefix__-message" type="hidden">
            <input id="id_external-inline-file-__prefix__-id" name="external-inline-file-__prefix__-id" type="hidden">
            <input id="id_external-inline-file-__prefix__-file" name="external-inline-file-__prefix__-file" type="file">
          </td>
          <td class="field">
            <input id="id_external-inline-file-__prefix__-DELETE" name="external-inline-file-__prefix__-DELETE" type="checkbox">
          </td>
        </tr>
        </tbody>
      </table>
      <button type="button" class="dynamic">Add file</button>
      </fieldset>
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc
    btn = doc.querySelector '.dynamic'
    parent = doc.querySelector 'table tbody'
    fieldset = doc.querySelector 'fieldset'

    form = new wzk.ui.inlineform.DynamicForm dom, {process: ->}

  test 'Should add a row', ->
    form.dynamic fieldset

    fireClick()

    assert.equal parent.children.length, 1
    assert.isNotNull doc.getElementById('id_external-inline-file-0-file'), 'Missing an expected cloned field'

  test 'Should disable the button, a count of forms is limited by MAX_NUM_FORMS', ->
    form.dynamic fieldset

    fireClick()
    fireClick()

    assert.equal parent.children.length, 2

  test 'A fieldset must contains an element with "dynamic" class', ->
    try
      form.dynamic fieldset
    catch err
      assert.instanceOf err, ReferenceError
