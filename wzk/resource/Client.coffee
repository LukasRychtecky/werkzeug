goog.provide 'wzk.resource.Client'

goog.require 'goog.events'
goog.require 'goog.net.EventType'
goog.require 'goog.json'
goog.require 'goog.net.XhrIo'
goog.require 'goog.net.IframeIo'
goog.require 'goog.object'
goog.require 'wzk.resource.UrlExpert'
goog.require 'wzk.resource.Model'
goog.require 'wzk.resource.ModelBuilder'
goog.require 'wzk.resource.Query'
goog.require 'wzk.net.XhrConfig'

class wzk.resource.Client

  ###*
    @enum {string}
  ###
  @X_HEADERS:
    TOTAL: 'X-Total'
    BASE: 'X-Base'
    OFFSET: 'X-Offset'
    NEXT_OFFSET: 'X-Next-Offset'
    PREV_OFFSET: 'X-Prev-Offset'
    ORDER: 'X-Order'
    REFERRER: 'X-Referer'
    EXTRA_FIELDS: 'X-Extra-Fields'
    FIELDS: 'X-Fields'
    SERIALIZATION_FORMAT: 'X-Serialization-Format'
    REQUESTED_WITH: 'X-Requested-With'
    NEXT_CURSOR: 'X-Next-Cursor'
    CURSOR: 'X-Cursor'

  ###*
    @enum {string}
  ###
  @HEADERS:
    ACCEPT: 'Accept'

  ###*
    @enum {string}
  ###
  @CONTENT_TYPE:
    APP_JSON: 'application/json'

  ###*
    @constructor
    @param {wzk.net.XhrFactory} xhrFac
    @param {string=} context
    @param {wzk.net.XhrConfig=} xhrConfig
  ###
  constructor: (@xhrFac, @context = '', @xhrConfig = new wzk.net.XhrConfig()) ->
    @headers = {}
    @headers[goog.net.XhrIo.CONTENT_TYPE_HEADER] = wzk.resource.Client.CONTENT_TYPE.APP_JSON
    @headers['Accept'] = wzk.resource.Client.CONTENT_TYPE.APP_JSON
    @expert = new wzk.resource.UrlExpert()
    @builder = new wzk.resource.ModelBuilder()

  ###*
    @param {string} k
    @param {string} v
  ###
  setDefaultHeader: (k, v) ->
    @headers[k] = v

  ###*
    @param {wzk.resource.Query} query
  ###
  setDefaultFields: (query) ->
    @headers[wzk.resource.Client.X_HEADERS.FIELDS] = query.composeFields() if query.hasFields()

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @param {Function} onError
  ###
  listenOnError: (xhr, onError = null) ->
    if onError?
      goog.events.listenOnce xhr, goog.net.EventType.ERROR, =>
        if @isJsonResponse(xhr) then onError xhr.getResponseJson() else onError(undefined)

  ###*
    @suppress {checkTypes}
    @param {Object|string} modelOrUrl
    @param {function(Array, Object)} onSuccess
    @param {Function=} onError
    @param {wzk.resource.Query|null|undefined=} query
  ###
  find: (modelOrUrl, onSuccess, onError = null, query = null) ->
    X = wzk.resource.Client.X_HEADERS
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      if onSuccess?
        result =
          total: parseInt xhr.getResponseHeader(X.TOTAL), 10
          nextOffset: parseInt xhr.getResponseHeader(X.NEXT_OFFSET)
          prevOffset: parseInt xhr.getResponseHeader(X.PREV_OFFSET)
          nextCursor: xhr.getResponseHeader(X.NEXT_CURSOR)
        onSuccess @builder.build(xhr.getResponseJson()), result

    @listenOnError xhr, onError

    headers = null
    if query?
      headers = {}
      goog.object.extend headers, @headers
      headers[X.BASE] = query.base if query.base?
      headers[X.OFFSET] = query.offset if query.offset?
      headers[X.ORDER] = query.sorting.toString()
      headers[X.REFERRER] = query.referer if query.referer?
      headers[X.FIELDS] = query.composeFields() if query.hasFields()
      headers[X.SERIALIZATION_FORMAT] = query.getSerFormat()
      headers[X.CURSOR] = query.cursor if query.cursor?
      headers[wzk.resource.Client.HEADERS.ACCEPT] = query.getAccept()

    method = 'GET'

    @send @getUrlFromModel(modelOrUrl, 'api-', method), method, xhr, null, headers

  ###*
    @protected
    @param {Object|string} modelOrUrl
    @param {string} resource
    @param {string} method
    @return {string}
  ###
  getUrlFromModel: (modelOrUrl, resource, method) ->
    url = ''
    if goog.isObject(modelOrUrl)
      method = 'GET'
      toks = [@expert.getUrl(modelOrUrl, resource + @context, method)]
      toks.push modelOrUrl['id']
      url = toks.join('/')
    else
      url = String(modelOrUrl)
    url

  ###*
    @param {Object|string} modelOrUrl
    @param {Function} onFetch
    @param {Function=} onError
  ###
  get: (modelOrUrl, onFetch, onError = null) ->
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      onFetch @builder.build xhr.getResponseJson()

    @listenOnError xhr, onError

    method = 'GET'

    @send @getUrlFromModel(modelOrUrl, 'api-resource-', method), method, xhr

  ###*
    @param {Object} model
    @param {Function=} onSuccess
    @param {Function=} onError
  ###
  delete: (model, onSuccess = null, onError = null) ->
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, ->
      onSuccess() if onSuccess?

    @listenOnError xhr, onError

    method = 'DELETE'
    url = @expert.getUrl model, 'api-resource-' + @context, method

    @send url, method, xhr

  ###*
    @param {Object} model
    @param {Function=} onSuccess
    @param {Function=} onError
  ###
  create: (model, onSuccess = null, onError = null) ->
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, ->
      onSuccess xhr.getResponseJson() if onSuccess?

    @listenOnError xhr, onError

    method = 'POST'
    url = @expert.getUrl model, 'api-' + @context, method

    @send url, method, xhr, goog.json.serialize(model)

  ###*
    @param {Object} model
    @param {Function=} onSuccess
    @param {Function=} onError
  ###
  update: (model, onSuccess = null, onError = null) ->
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, ->
      onSuccess xhr.getResponseJson() if onSuccess?

    @listenOnError xhr, onError

    method = 'PUT'
    url = @expert.getUrl model, 'api-resource-' + @context, method

    @send "#{url}/#{model['id']}", method, xhr, goog.json.serialize(model)

  ###*
    @param {string} url
    @param {string} method
    @param {Object|null|string=} content
    @param {Function=} onSuccess
    @param {Function=} onError
    @param {boolean=} responseAsModel
    @param {Object.<string, string>=} headers
  ###
  request: (url, method, content = {}, onSuccess = null, onError = null, responseAsModel = false, headers = {}) ->
    xhr = @xhrFac.build @xhrConfig

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      if onSuccess
        onSuccess(if responseAsModel then @builder.build(xhr.getResponseJson()) else @tryResponseAsJson(xhr))

    @listenOnError xhr, onError
    goog.object.extend headers, @headers

    @send url, method, xhr, content, headers

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @return {*}
  ###
  tryResponseAsJson: (xhr) ->
    res = null
    try
      res = xhr.getResponseJson()
    catch err
      res = xhr.getResponseText()
    res

  ###*
    Loads a Html snippet from a server. First it tries to parse a response as a JSON.
    If the response is a JSON returns it. Otherwise return response as a string.

    @param {string} url
    @param {function(Object)} onSuccess
    @param {function()|null=} onError
  ###
  sniff: (url, onSuccess, onError = null) ->
    xhr = @xhrFac.build @xhrConfig
    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      res = (`/** @type {Object} */`) @tryResponseAsJson(xhr)
      onSuccess res

    @listenOnError xhr, onError

    @send url, 'GET', xhr, null, {'Accept': 'text/html,application/json'}

  ###*
    @protected
    @param {string} url
    @param {string} method
    @param {wzk.net.XhrIo=} xhr
    @param {null|string|Object|undefined=} content
    @param {Object|null|undefined=} headers
  ###
  send: (url, method, xhr = null, content = null, headers = null) ->

    if goog.isObject content
      content = goog.json.serialize content

      unless goog.array.find goog.object.getKeys(headers), @containsContentType
        headers[goog.net.XhrIo.CONTENT_TYPE_HEADER] = wzk.resource.Client.CONTENT_TYPE.APP_JSON

    xhr = @xhrFac.build @xhrConfig unless xhr?
    xhr.send url, method, content, headers ? @headers

  ###*
    @param {string} header
    @return {boolean}
  ###
  containsContentType: (header) ->
    goog.string.caseInsensitiveEquals goog.net.XhrIo.CONTENT_TYPE_HEADER, header

  ###*
    @param {string} url
    @param {string|Object} content
    @param {function(Object)} onSuccess
    @param {function(string=)} onError
  ###
  postForm: (url, content, onSuccess, onError) ->
    xhr = @xhrFac.build @xhrConfig

    xhr.listenOnce goog.net.EventType.SUCCESS, =>
      if xhr.getResponseHeader('Location')?
        @reload xhr.getResponseHeader('Location')
      else if @isHtmlResponse(xhr)
        onError xhr.getResponseText()
      else
        try
          # try parse response as JSON
          onSuccess (`/** @type {Object} */`) xhr.getResponseJson() ? {}
        catch e
          onSuccess {}

    @listenOnError xhr, onError

    headers =
      'Accept': 'text/html,application/json'
      'Content-Type': 'application/x-www-form-urlencoded'
    headers[wzk.resource.Client.X_HEADERS.REQUESTED_WITH] = 'XMLHttpRequest'
    @send url, 'POST', xhr, content, headers

  ###*
    @protected
    @param {string} location
  ###
  reload: (location) ->
    @xhrFac.getLocation().assign location
    @xhrFac.getLocation().reload true

  ###*
    Posts given form in Iframe
    Uses gog.net.IframeIo, which extracts action and method from form element
    Automatically handles snippets and flashes, using delegation to xhrFactory
    @param {HTMLFormElement} form
    @param {function(Object)} onSuccess
    @param {function(string=)} onError
  ###
  postFormIframe: (form, onSuccess, onError) ->
    iframeIO = new goog.net.IframeIo()
    iframeIO.sendFromForm (`/** @type {HTMLFormElement} */`) form

    iframeIO.listen goog.net.EventType.SUCCESS, (event) =>
      response = event.target.getResponseJson()
      if response['location']?
        @reload response['location']
      else
        onSuccess response
        @xhrFac.applyJsonResponse response, @xhrConfig, 200

    iframeIO.listen goog.net.EventType.ERROR, (event) ->
      onError event.target.getResponseText()

  ###*
    Posts form as iframe, if form contains any files (input[type=file])
    Sends as ajax request otherwise
    @param {HTMLFormElement} form
    @param {function(Object)} onSuccess
    @param {function(string=)} onError
  ###
  postFormIframeIfContainsFiles: (form, onSuccess, onError) ->
    if @formContainsFile(form)
      @postFormIframe form, onSuccess, onError
    else
      url = form.action
      data = goog.dom.forms.getFormDataString form
      @postForm url, data, onSuccess, onError

  ###*
    @protected
    @param {HTMLFormElement} form
    @return {boolean}
  ###
  formContainsFile: (form) ->
    for fileInput in form.querySelectorAll('input[type=file]')
      if !!goog.dom.forms.getValue fileInput
        return true
    return false

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @return {boolean}
  ###
  isJsonResponse: (xhr) ->
    @isExpectedResponse xhr, 'application/json'

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @return {boolean}
  ###
  isHtmlResponse: (xhr) ->
    @isExpectedResponse xhr, 'text/html'

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @param {string} type
    @return {boolean}
  ###
  isExpectedResponse: (xhr, type) ->
    return false unless xhr.getResponseHeader('Content-Type')
    xhr.getResponseHeader('Content-Type').indexOf(type) isnt -1
