goog.require 'goog.dom.dataset'
goog.require 'goog.crypt.base64'

class wzk.ui.grid.ExportButton extends wzk.ui.Button

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

  ###*
    @param {Object} params
      watcher: {wzk.ui.grid.FilterWatcher}
  ###
  constructor: (params) ->
    super params
    {@watcher, @client} = params
    @type = null
    @fileName = null
    @ext = null

  ###*
    @override
  ###
  decorateInternal: (el) ->
    super el
    @listen goog.ui.Component.EventType.ACTION, @handleAction
    undefined

  ###*
    @protected
    @return {string}
  ###
  getType: ->
    unless @type
      LOOKUP = wzk.ui.grid.ExportButton.LOOKUP
      @type = if LOOKUP[@getExtension()]? then LOOKUP[@getExtension()] else 'application/octet-stream'
    @type

  ###*
    @protected
    @return {string|undefined}
  ###
  getExtension: ->
    unless @ext
      @ext = goog.dom.dataset.get(@getElement(), wzk.ui.grid.ExportButton.DATA.TYPE) ? ''
      @ext = String @ext
    @ext

  ###*
    @protected
  ###
  handleAction: =>
    headers = {}
    headers[wzk.resource.Client.HEADERS.ACCEPT] = @getType()
    @client.request @watcher.getQuery().composePath(), 'GET', {}, @handleSuccess, null, false, headers

  ###*
    @protected
    @param {string} res
  ###
  handleSuccess: (res) =>
    attrs =
      'download': @getFileName()
      'href': ['data:', @getType(), ';base64,', @encodeUtf8(res)].join ''
      'style': 'display:none'
    @dom.el('a', attrs, @dom.getDocument().body).click()

  ###*
    @protected
    @return {string}
  ###
  getFileName: ->
    unless @fileName
      @fileName = goog.dom.dataset.get(@getElement(), wzk.ui.grid.ExportButton.DATA.FILE)
      unless @fileName?
        @fileName = "download.#{@getExtension()}"
    @fileName

  ###*
    @protected
    @param {string} s
    @return {string}
  ###
  encodeUtf8: (s) ->
    win = @dom.getWindow()
    goog.crypt.base64.encodeString win.unescape win.encodeURIComponent s
