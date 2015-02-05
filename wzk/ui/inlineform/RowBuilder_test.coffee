suite 'wzk.ui.inlineform.RowBuilder', ->
  E = wzk.ui.inlineform.RowBuilder.EventType

  builder = null
  row = null
  expert = null
  doc = null
  dom = null
  parent = null
  checkbox = null

  fireCheckboxClick = ->
    e =
      type: 'click'
      target: row
      preventDefault: ->
    checkbox.parentNode.querySelector('.goog-icon-remove')._listeners['click'].false[0].listener.listener e

  setup ->
    doc = jsdom """
    <html><head></head>
    <body>
      <table class="form">
        <tbody>
        <tr class="odd">
          <td class="field">
            <input id="id_external-inline-file-__prefix__-message" name="external-inline-file-__prefix__-message" type="hidden">
            <input id="id_external-inline-file-__prefix__-id" name="external-inline-file-__prefix__-id" type="hidden">
            <input id="id_external-inline-file-__prefix__-file" name="external-inline-file-__prefix__-file" type="file">
            <textarea id="id_external-inline-file-__prefix__-note" name="external-inline-file-__prefix__-note"></textarea>
          </td>
          <td class="field">
            <input id="id_external-inline-file-__prefix__-DELETE" name="external-inline-file-__prefix__-DELETE" type="checkbox">
          </td>
        </tr>
        </tbody>
      </table>
    </body>
    </html>
    """
    dom = new wzk.dom.Dom doc
    row = doc.querySelector 'table tr'
    parent = doc.querySelector 'table tbody'
    checkbox = doc.querySelector 'table input[type=checkbox]'
    expert = new wzk.ui.inlineform.FieldExpert(1)
    builder = new wzk.ui.inlineform.RowBuilder(row, expert, dom)

  test 'Should add a row', ->
    builder.addRow()

    assert.equal parent.children.length, 2
    assert.isNotNull doc.getElementById 'id_external-inline-file-1-file'
    row = parent.children[1]
    assert.equal row.className, 'even'
    assert.equal row.querySelector('textarea').id, 'id_external-inline-file-1-note'

  test 'Should fire a delete event on click', (done) ->
    goog.events.listen builder, E.DELETE, (e) ->
      done() if e.target is row

    builder.addRow()
    builder.decorateRow row

    fireCheckboxClick()
