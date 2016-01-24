goog.require 'wzk.resource.Model'


class wzk.ui.ac.RESTArrayMatcher extends goog.ui.ac.RemoteArrayMatcher

  ###*
    @constructor
    @extends {goog.ui.ac.RemoteArrayMatcher}
    An array matcher that requests matches via ajax.
    @param {string} url The Uri which generates the auto complete matches.  The
      search term is passed to the server as the 'token' query param.
    @param {string=} tokenName a token URL parameter name
    @param {number=} limit a limit for a response objects count
    @param {number=} tokenMinLength a token min. length when a request an be fired
    @param {Array.<string>=} fields a list of object fields names requested via AJAX
  ###
  constructor: (url, @tokenName = 'token', @limit = 100, @tokenMinLength = 3, @fields = []) ->
    super(url, false)
    @headers = {
      'X-Fields': @fields.join(','),
      'X-Base': @limit,
    }

  ###*
    @override
  ###
  shouldRequestMatches: (uri, token, maxMatches, useSimilar, fullString) ->
    return token? and token.length >= @tokenMinLength

  ###*
    @protected
    @param {string} token
    @param {function(string, Array)} matchHandler
    @param {goog.events.Event} event
  ###
  handleMatches: (token, matchHandler, event) ->
    matchHandler(token, (new wzk.resource.Model(obj) for obj in event.target.getResponseJson()))

  ###*
    @override
  ###
  buildUrl: (uri, token, maxMatches, useSimilar, fullString) ->
    url = new goog.Uri(uri)
    url.setParameterValue(@tokenName, token)
    return url.toString()

  ###*
    @override
    @suppress {visibility}
  ###
  requestMatchingRows: (token, maxMatches, matchHandler, fullString) ->
    return unless @shouldRequestMatches(@url_, token, maxMatches, @useSimilar_, fullString)

    url = @buildUrl(@url_, token, maxMatches, @useSimilar_, fullString)

    # This ensures if previous XHR is aborted or ends with error, the
    # corresponding success-callbacks are cleared.
    if @lastListenerKey_
      goog.events.unlistenByKey(@lastListenerKey_)
      @xhr_.abort()

    callback = goog.bind(@handleMatches, @, token, matchHandler)

    @lastListenerKey_ = goog.events.listenOnce(@xhr_, goog.net.EventType.SUCCESS, callback)
    @xhr_.send(url, @method_, @content_, @headers)
