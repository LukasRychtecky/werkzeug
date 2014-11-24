goog.require 'goog.dom.dataset'
goog.require 'goog.crypt.base64'
goog.require 'goog.Uri'

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
    @protected
    @param {goog.events.Event} e
  ###
  handleAction: (e) =>
    uri = @watcher.getQuery().cloneUri()
    uri.setParameterValue '_accept', @getType()
    for k in @implicitUriParams.getKeys() when not uri.getParameterValue(k)?
      uri.setParameterValue k, @implicitUriParams.getValues k
    @getElement().href = uri.toString()
