class wzk.net.XhrConfig

  ###*
    @param {Object.<boolean>=} params
      flash: false to skip all flashes
      loading: false to skip a loading flash
      snippet: false to skip snippets
  ###
  constructor: (params = {}) ->
    {@flash, @loading, @snippet} = params
    @flash ?= true
    @loading ?= true
    @snippet ?= true
