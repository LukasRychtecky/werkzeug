class wzk.net.ReloadMiddleware extends wzk.net.ResponseMiddleware

  ###*
    @param {Window} win
  ###
  constructor: (@win) ->

  ###*
    @override
  ###
  apply: (e) ->
    if e.target.getStatus() is 401
      @win.location.reload(true)
