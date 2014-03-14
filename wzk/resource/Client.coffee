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

class wzk.resource.Client

  ###*
    @enum {string}
  ###
  @X_HEADERS:
    TOTAL: 'X-Total'
    BASE: 'X-Base'
    OFFSET: 'X-Offset'
    ORDER: 'X-Order'
    DIRECTION: 'X-Direction'
    REFERRER: 'X-Referer'
    EXTRA_FIELDS: 'X-Extra-Fields'
    SERIALIZATION_FORMAT: 'X-Serialization-Format'

  ###*
    @constructor
    @param {wzk.net.XhrFactory} xhrFac
    @param {string=} context
  ###
  constructor: (@xhrFac, @context = '') ->
    @headers = {}
    @headers[goog.net.XhrIo.CONTENT_TYPE_HEADER] = 'application/json'
    @headers['Accept'] = 'application/json'
    @expert = new wzk.resource.UrlExpert()
    @builder = new wzk.resource.ModelBuilder()

  ###*
    @param {wzk.resource.Query} query
  ###
  setDefaultExtraFields: (query) ->
    @headers[wzk.resource.Client.X_HEADERS.EXTRA_FIELDS] = query.composeExtraFields() if query.hasExtraFields()

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
    xhr = @xhrFac.build()

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      if onSuccess?
        result =
          total: parseInt xhr.getResponseHeader(X.TOTAL), 10
        onSuccess @builder.build(xhr.getResponseJson()), result

    @listenOnError xhr, onError

    headers = null
    if query?
      headers = {}
      goog.object.extend headers, @headers
      headers[X.BASE] = query.base if query.base?
      headers[X.OFFSET] = query.offset if query.offset?
      headers[X.ORDER] = query.order if query.order?
      headers[X.DIRECTION] = query.direction if query.direction?
      headers[X.REFERRER] = query.referer if query.referer?
      headers[X.EXTRA_FIELDS] = query.composeExtraFields() if query.hasExtraFields()
      headers[X.SERIALIZATION_FORMAT] = query.getSerFormat()

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
    xhr = @xhrFac.build()

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      onFetch @builder.build(xhr.getResponseJson())

    @listenOnError xhr, onError

    method = 'GET'

    @send @getUrlFromModel(modelOrUrl, 'api-resource-', method), method, xhr

  ###*
    @param {Object} model
    @param {Function=} onSuccess
    @param {Function=} onError
  ###
  delete: (model, onSuccess = null, onError = null) ->
    xhr = @xhrFac.build()

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
    xhr = @xhrFac.build()

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
    xhr = @xhrFac.build()

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
  ###
  request: (url, method, content = {}, onSuccess = null, onError = null, responseAsModel = false) ->
    xhr = @xhrFac.build()

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      onSuccess(if responseAsModel then @builder.build(xhr.getResponseJson()) else xhr.getResponseJson()) if onSuccess

    @listenOnError xhr, onError

    @send url, method, xhr, content

  ###*
    Loads a Html snippet from a server.

    @param {string} url
    @param {function(string)} onSuccess
    @param {function()|null=} onError
  ###
  sniff: (url, onSuccess, onError = null) ->
    xhr = @xhrFac.build()
    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, ->
      onSuccess xhr.getResponseText()

    @listenOnError xhr, onError

    @send url, 'GET', xhr, null, {'Accept': 'text/html'}

  ###*
    @protected
    @param {string} url
    @param {string} method
    @param {wzk.net.XhrIo=} xhr
    @param {null|string|Object|undefined=} content
    @param {Object|null|undefined=} headers
  ###
  send: (url, method, xhr = null, content = null, headers = null) ->

    content = goog.json.serialize content if goog.isObject(content)

    xhr = @xhrFac.build() unless xhr?
    xhr.send url, method, content, headers ? @headers

  ###*
    @param {string} url
    @param {string|Object} content
    @param {function(Object)} onSuccess
    @param {function(string=)} onError
  ###
  postForm: (url, content, onSuccess, onError) ->
    xhr = @xhrFac.build()

    xhr.listenOnce goog.net.EventType.SUCCESS, =>
      if @isHtmlResponse(xhr)
        onError xhr.getResponseText()
      else if @isJsonResponse(xhr)
        onSuccess (`/** @type {Object} */`) xhr.getResponseJson() ? {}

    @listenOnError xhr, onError

    headers =
      'Accept': 'text/html,application/json'
      'Content-Type': 'application/x-www-form-urlencoded'
    @send url, 'POST', xhr, content, headers

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
      onSuccess response
      @xhrFac.applyJsonResponse response

    iframeIO.listen goog.net.EventType.ERROR, (event) =>
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
