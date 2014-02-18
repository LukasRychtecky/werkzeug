goog.provide 'wzk.resource.Client'

goog.require 'goog.events'
goog.require 'goog.net.EventType'
goog.require 'goog.json'
goog.require 'goog.net.XhrIo'
goog.require 'goog.object'
goog.require 'wzk.resource.UrlExpert'
goog.require 'wzk.resource.Model'
goog.require 'wzk.resource.ModelBuilder'

class wzk.resource.Client

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
    @param {Object|null|undefined=} query
  ###
  find: (modelOrUrl, onSuccess, onError = null, query = null) ->

    xhr = @xhrFac.build()

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      if onSuccess?
        result =
          total: parseInt xhr.getResponseHeader('X-Total'), 10
        onSuccess @builder.build(xhr.getResponseJson()), result

    @listenOnError xhr, onError

    headers = null
    if query?
      headers = {}
      goog.object.extend headers, @headers
      headers["X-Base"] = query.base if query.base?
      headers["X-Offset"] = query.offset if query.offset?
      headers["X-Order"] = query.order if query.order?
      headers["X-Direction"] = query.direction if query.direction?
      headers['X-Referer'] = query.referer if query.referer?

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

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
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

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
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

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
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
  ###
  request: (url, method, content = {}, onSuccess = null, onError = null) ->
    xhr = @xhrFac.build()

    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
      onSuccess xhr.getResponseJson() if onSuccess?

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
    goog.events.listenOnce xhr, goog.net.EventType.SUCCESS, =>
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
