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
    super(el)
    goog.events.listen(el, goog.events.EventType.CLICK, @handleAction)
    @origUri = new goog.Uri(@getElement().href)
    @implicitUriParams = @origUri.getQueryData()
    @implicitUriParams.remove(col) for col in @watcher.getGrid().getColumns()
    undefined

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
    uri.setPath(@origUri.getPath())
    for k in @implicitUriParams.getKeys() when not uri.getParameterValue(k)?
      uri.setParameterValue k, @implicitUriParams.getValues(k)
    uri.toString()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleAction: (e) =>
    @getElement().href = @buildUri()
