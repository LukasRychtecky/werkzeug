class wzk.ui.grid.Updater

  ###*
    @enum {string}
  ###
  @DATA:
    URL: 'updateUrl'
    INTERVAL: 'updateInterval'

  ###*
    @const
    @type {number}
  ###
  @REFRESH_INTERVAL: 3000

  ###*
    @constructor
    @param {wzk.ui.grid.Grid} grid
    @param {wzk.resource.Client} client
    @param {string} url
    @param {number=} interval
  ###
  constructor: (@grid, @client, @url, interval = wzk.ui.grid.Updater.REFRESH_INTERVAL) ->
    @timer = new goog.Timer interval
    @timer.listen goog.Timer.TICK, @fetch

  start: ->
    @timer.start()

  ###*
    @protected
  ###
  fetch: =>
    @timer.stop()
    @client.find @url, @update

  ###*
    @protected
    @param {wzk.resource.Model|Array.<wzk.resource.Model>} data
    @param {Object} result
  ###
  update: (data, result) =>
    if data['count-changed'] > 0
      @grid.refresh()
    @timer.start()
