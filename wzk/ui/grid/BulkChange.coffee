goog.provide 'wzk.ui.grid.BulkChange'

goog.require 'goog.dom.classes'
goog.require 'goog.events'
goog.require 'goog.json'
goog.require 'goog.object'
goog.require 'goog.string'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.ui.Button'
goog.require 'wzk.ui.dialog.SnippetModal'
goog.require 'wzk.ui.form.buttons'
goog.require 'wzk.ui.form.Checkbox'
goog.require 'wzk.ui.grid.Row'


class wzk.ui.grid.BulkChange

  ###*
    @enum {string}
  ###
  @CLS =
    SELECTED: 'field-selected'
    UNSELECTED: 'field-unselected'

  ###*
    @enum {string}
  ###
  @DATA =
    SNIPPET: 'formSnippet'
    API: 'apiUrl'
    FORM: 'formUrl'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.resource.Client} client
    @param {wzk.ui.grid.Grid} grid
    @param {wzk.app.Register} reg
  ###
  constructor: (@dom, @client, @grid, @reg, @flash) ->
    @btn = new wzk.ui.Button(dom: @dom)
    @fieldsToEls = {}
    @selectedInputs = {}
    @selectedRows = []
    @form = null
    @fields = null

  ###*
    @protected
    @param {Array} params
  ###
  parseDataParams: (params) ->
    parsed = []
    for param in params
      unparsed = wzk.dom.dataset.get(@el, param)
      if unparsed
        parsed.push(String(unparsed))
      else
        throw Error("Missing `data-#{param}` for BulkChange")
    return parsed

  ###*
    @param {Element} el
  ###
  decorate: (@el) ->
    DATA = wzk.ui.grid.BulkChange.DATA
    [@formSnippet, @apiUrl, @formUrl] = @parseDataParams([DATA.SNIPPET, DATA.API, DATA.FORM])

    @btn.decorate(@el)
    @btn.listen(goog.ui.Component.EventType.ACTION, @handleClick)
    @btn.setEnabled(false)
    goog.events.listen(@grid, wzk.ui.grid.Row.EventType.SELECTION_CHANGE, @handleRowsSelectionChange)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleClick: (e) =>
    return unless @btn.isEnabled()

    modal = new wzk.ui.dialog.SnippetModal(
      @dom, @client, [@formUrl, '?snippet=', @formSnippet].join(''), @formSnippet, @reg)
    modal.listen(wzk.ui.dialog.SnippetModal.EVENTS.OPEN, @handleOpen)
    modal.open()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSubmit: (e) =>
    data = {}
    for name, input of @selectedInputs
      data[name] = goog.dom.forms.getValue(input)

    @client.request(
      [@apiUrl, '?id__in=', goog.json.serialize(row.getModel()['id'] for row in @selectedRows)].join(''),
      'PUT',
      data,
      @handleComplete,
      @handleError
    )

  ###*
    @protected
    @param {Object} response
  ###
  handleComplete: (response) =>
    @dom.getWindow().location.reload(true)

  ###*
    @protected
    @param {Object} response
    @return {string|null}
  ###
  composeBulkErrorMessage: (response) =>
    errorIds = wzk.array.map(response['messages']?['errors'], (obj) -> obj['id'])

    if wzk.array.isEmpty(errorIds)
      null
    else
      goog.string.format(
        wzk.dom.dataset.get(
          @el,
          'bulkErrorMessage',
          String,
          'Please fix errors for following objects: %s'
        ),
        errorIds.join(', ')
      )

  ###*
    Removes errorlist element from DOM if exists
    @protected
    @param {Element} el
  ###
  removeErrorList: (el) =>
    errorListEl = @dom.cls('errorlist', el)
    if errorListEl?
      @dom.removeNode(errorListEl)

  ###*
    Displays new errors or remove old ones.
    @protected
    @param {Object.<string, string>} allErrors
  ###
  displayOrRemoveFieldsErrors: (allErrors) =>
    for field, el of @fieldsToEls
      if goog.object.containsKey(allErrors, field)
        goog.dom.classlist.add(el, 'error')
        @removeErrorList(el)
        @dom.appendChild(el, @dom.el('ul', 'errorlist', [@dom.el('li', null, allErrors[field])]))
      else
        goog.dom.classlist.remove(el, 'error')
        @removeErrorList(el)

  ###*
    @protected
    @param {Object} response
  ###
  handleError: (response) =>
    bulkErrorMessage = @composeBulkErrorMessage(response)
    if bulkErrorMessage?
      @flash.addError(bulkErrorMessage)

    @displayOrRemoveFieldsErrors(
      wzk.array.reduce(
        response['messages']['errors'],
        (acc, field) -> wzk.obj.merge(acc, field['errors']),
        {}
      )
    )

    if @form?
      wzk.ui.form.buttons.enableInForm(@form, @dom)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleOpen: (e) =>
    @selectedInputs = {}
    @selectedRows = @grid.getSelectedRows()

    content = e.target.getContentElement()
    btnEl = @dom.cls('btn-save', content)
    if btnEl?
      @submitBtn = new wzk.ui.Button(dom: @dom)
      @submitBtn.decorate(btnEl)
      @submitBtn.setEnabled(false)
      @submitBtn.listen(goog.ui.Component.EventType.ACTION, @handleSubmit)

    @form = @dom.one('form', content)
    if @form?
      goog.events.listen(@form, goog.events.EventType.SUBMIT, (e) -> e.preventDefault())

    summary = @dom.cls('bulk-change-object-summary', content)
    if summary?
      @dom.setTextContent(summary, goog.string.format(@dom.getTextContent(summary), @selectedRows.length))

    for field in @dom.clss('field', content)
      target = @extractInputName(@findSelectedInput(field))
      @decorateField(field, @extractInputName(@findSelectedInput(field)))
      @fieldsToEls[target] = field

  ###*
    @protected
    @param {Element} field
  ###
  decorateField: (field, target) ->
    goog.dom.classes.add(field, wzk.ui.grid.BulkChange.CLS.UNSELECTED)
    checkbox = new wzk.ui.form.Checkbox(dom: @dom)
    checkbox.render(field)
    wzk.dom.dataset.set(checkbox.getElement(), 'target', target)
    checkbox.listen(wzk.ui.form.Field.EVENTS.CHANGE, @handleSelect)
    return checkbox

  ###*
    @protected
    @param {Element} field
    @param {boolean} checked
  ###
  swapClasses: (field, checked) ->
    CLS = wzk.ui.grid.BulkChange.CLS
    classes = if checked then [CLS.SELECTED, CLS.UNSELECTED] else [CLS.UNSELECTED, CLS.SELECTED]
    for func, i in [goog.dom.classes.add, goog.dom.classes.remove]
      func(field, classes[i])

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelect: (e) =>
    field = @fieldsToEls[wzk.dom.dataset.get(e.target.target, 'target')]
    unless field?
      @dom.getWindow().console.warn("Given an invalid checkbox ID #{e.target.getId()} for BulkChange")
      return

    checked = e.target.target.checked
    @swapClasses(field, checked)

    selectedInput = @findSelectedInput(field)
    unless selectedInput?
      @dom.getWindow().console.warn("Missing an input in field .#{field.className}")
      return

    if checked
      goog.object.set(@selectedInputs, @extractInputName(selectedInput), selectedInput)
    else
      goog.object.remove(@selectedInputs, @extractInputName(selectedInput))

    @submitBtn.setEnabled(checked or goog.object.getCount(@selectedInputs))

  ###*
    @protected
    @param {Element} field
  ###
  findSelectedInput: (field) ->
    return @dom.one('input, select, textarea', field)

  ###*
    @protected
    @param {Element} input
    @return {string}
  ###
  extractInputName: (input) ->
    return wzk.array.last(input.name.split('-')[-1..])

  ###*
    @protected
  ###
  handleRowsSelectionChange: =>
    @selectedRows = @grid.getSelectedRows()
    @btn.setEnabled(@selectedRows.length > 0)
