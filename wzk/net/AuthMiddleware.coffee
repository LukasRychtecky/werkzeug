goog.require 'goog.net.Cookies'

class wzk.net.AuthMiddleware extends wzk.net.HeadersMiddleware

  ###*
    @enum {string}
  ###
  @HEADER:
    AUTH: 'Authorization'

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
    auth  = @cookies.get wzk.net.AuthMiddleware.HEADER.AUTH
    if auth?
      headers[wzk.net.AuthMiddleware.HEADER.AUTH] = auth
    undefined # Coffee & Closure
