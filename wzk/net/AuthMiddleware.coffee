goog.require 'goog.array'
goog.require 'goog.dom.dataset'
goog.require 'goog.net.Cookies'
goog.require 'goog.json'


class wzk.net.AuthMiddleware extends wzk.net.HeadersMiddleware

  ###*
    @enum {string}
  ###
  @HEADER:
    AUTH: 'Authorization'
    CSRF: 'X-CsrfToken'

  ###*
    @enum {string}
  ###
  @COOKIES:
    CSRF: 'csrftoken'

  ###*
    @param {Document} doc
  ###
  constructor: (doc) ->
    super()
    @cookies = new goog.net.Cookies(doc)
    @csrf = @parseCSRFFromInitialData(doc)

  ###*
    @param {Object} headers
  ###
  apply: (headers) ->
    csrfs = (token for token in [@csrf, @cookies.get(wzk.net.AuthMiddleware.COOKIES.CSRF)] when token?)
    if not goog.array.isEmpty(csrfs)
      headers[wzk.net.AuthMiddleware.HEADER.CSRF] = csrfs[0]
    else
      auth  = @cookies.get wzk.net.AuthMiddleware.HEADER.AUTH
      if auth?
        headers[wzk.net.AuthMiddleware.HEADER.AUTH] = auth
    undefined # Coffee & Closure

  ###*
    @protected
    @param {string?} str
    @return {boolean}
  ###
  isBlank: (str) ->
    not str? or str is ''

  ###*
    @protected
    @param {Element?} el
    @return {boolean}
  ###
  hasInitialData: (el) ->
    el? and not @isBlank(goog.dom.dataset.get(el, 'initial'))

  ###*
    @protected
    @param {Document} doc
    @return {string?}
  ###
  parseCSRFFromInitialData: (doc) ->
    elements = (el for el in [document.body, document.getElementById('wrapper')] when @hasInitialData(el))
    if goog.array.isEmpty(elements)
      return null
    else
      return goog.json.parse(goog.dom.dataset.get(elements[0], 'initial'))?['net']?['csrf-token']
