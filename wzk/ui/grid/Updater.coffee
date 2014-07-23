class wzk.ui.grid.Updater

  ###*
    @const
    @type {string}
  ###
  @UPDATE_URL: 'updateUrl'

  ###*
    @const
    @type {int}
  ###
  @REFRESH_INTERVAL: 3000

  ###*
    @constructor
    @param {wzk.ui.grid.Grid} grid
    @param {string} url
    @param {wzk.resource.Client} client
  ###
  constructor: (@grid, @url, @client) ->
    @timer = new goog.Timer wzk.ui.grid.Updater.REFRESH_INTERVAL
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
    @param {wzk.resource.Model} data
  ###
  update: (data) =>
    if data['count-changed'] > 0
      @grid.refresh()
    @timer.start()
