goog.require 'goog.dom.dataset'
goog.require 'goog.crypt.base64'
goog.require 'goog.Uri'
goog.require 'wzk.ui.grid.FilterWatcher'
goog.require 'wzk.resource.Query'
goog.require 'wzk.resource.FilterValue'

class wzk.ui.grid.ExportLink extends wzk.ui.Link

  ###*
    @const
    @type {string}
  ###
  @CLS = 'export'

  ###*
    @enum {string}
  ###
  @DATA:
    FILE: 'fileName'
    TYPE: 'type'

  ###*
    @enum {string}
  ###
  @LOOKUP:
    'csv': 'text/csv'
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    'xml': 'text/xml'
    'json': 'application/json'
    'yaml': 'application/x-yaml'
    'picle': 'application/python-pickle'
    'pdf': 'application/pdf'

  ###*
    @param {Object} params
      watcher: {wzk.ui.grid.FilterWatcher}
      client: {wzk.resource.Client}
  ###
  constructor: (params) ->
    super params
    {@watcher, @client} = params
    @type = null
    @ext = null

  ###*
    @override
  ###
  decorateInternal: (el) ->
    super el
    goog.events.listen el, goog.events.EventType.CLICK, @handleAction
    @implicitUriParams = new goog.Uri(@getElement().href).getQueryData()
    @implicitUriParams.remove(col) for col in @watcher.getGrid().getColumns()
    undefined

  ###*
    @protected
    @return {string}
  ###
  getType: ->
    unless @type
      LOOKUP = wzk.ui.grid.ExportLink.LOOKUP
      @type = if LOOKUP[@getExtension()]? then LOOKUP[@getExtension()] else 'application/octet-stream'
    @type

  ###*
    @protected
    @return {string|undefined}
  ###
  getExtension: ->
    unless @ext
      @ext = goog.dom.dataset.get(@getElement(), wzk.ui.grid.ExportLink.DATA.TYPE) ? ''
      @ext = String @ext
    @ext

  ###*
    @return {string}
  ###
  buildUri: ->
    uri = @watcher.getQuery().cloneUri()
    uri.setParameterValue '_accept', @getType()
    for k in @implicitUriParams.getKeys() when not uri.getParameterValue(k)?
      uri.setParameterValue k, @implicitUriParams.getValues(k)
    uri.toString()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleAction: (e) =>
    @getElement().href = @buildUri()
