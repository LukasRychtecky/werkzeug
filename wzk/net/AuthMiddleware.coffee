goog.require 'goog.net.Cookies'

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
    @cookies = new goog.net.Cookies doc

  ###*
    @param {Object} headers
  ###
  apply: (headers) ->
    csrf = @cookies.get wzk.net.AuthMiddleware.COOKIES.CSRF
    if csrf
      headers[wzk.net.AuthMiddleware.HEADER.CSRF] = csrf
    else
      auth  = @cookies.get wzk.net.AuthMiddleware.HEADER.AUTH
      if auth?
        headers[wzk.net.AuthMiddleware.HEADER.AUTH] = auth
    undefined # Coffee & Closure
