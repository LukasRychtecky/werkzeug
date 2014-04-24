goog.require 'wzk.ui.grid.Grid'
goog.require 'goog.dom.dataset'

class wzk.ui.grid.PaneMode

  ###*
    @enum {string}
  ###
  @ATTRS:
    LINK: 'webLink'

  ###*
    @type {string}
  ###
  @PARAM: 'i'

  ###*
    @enum {string}
  ###
  @DATA:
    MODE: 'mode'
    SNIPPET: 'snippet'

  ###*
    @param {Element} table
    @return {boolean}
  ###
  @usePane: (table) ->
    mode = goog.dom.dataset.get table, wzk.ui.grid.PaneMode.DATA.MODE
    mode? and mode is 'pane'

  ###*
    @param {wzk.resource.Client} client
    @param {wzk.dom.Dom} dom
    @param {wzk.app.Register} reg
    @param {wzk.stor.StateStorage} ss
    @param {wzk.resource.Query} query
  ###
  constructor: (@client, @dom, @reg, @ss, @query) ->

  ###*
    @param {wzk.ui.grid.Grid} grid
  ###
  watchOn: (grid) ->
    grid.listen wzk.ui.grid.Grid.EventType.SELECTED_ITEM, @handleSelected
    grid.listen wzk.ui.grid.Grid.EventType.LOADED, @handleLoadedGrid
    @loadModel()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleLoadedGrid: (e) =>
    e.currentTarget.selectIfContains @modelToSelect if @modelToSelect

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelected: (e) =>
    @loadSnippets (`/** @type {wzk.resource.Model} */`) e.target

  ###*
    @protected
  ###
  loadModel: ->
    id = @ss.get wzk.ui.grid.PaneMode.PARAM
    if id
      @client.get @query.composeGet(id), @loadSnippets

  ###*
    @protected
    @param {wzk.resource.Model} modelToSelect
  ###
  loadSnippets: (@modelToSelect) =>
    @ss.set wzk.ui.grid.PaneMode.PARAM, @modelToSelect['id']
    A = wzk.ui.grid.PaneMode.ATTRS
    for el in @dom.all '.snippet[data-web-link]'
      link = @parseLink String goog.dom.dataset.get(el, A.LINK)
      url = @modelToSelect['_web_links'][link.link]

      if link.index?
        url = url[link.index]
      if url?
        @processSnippet url

  ###*
    @protected
    @param {string} attr
    @return {Object}
  ###
  parseLink: (attr) ->
    tokens = attr.split '.'
    link: tokens[0]
    index: (if tokens[1]? then tokens[1] else null)

  ###*
    @protected
    @param {string} url
  ###
  processSnippet: (url) ->
    @client.request url, 'GET'
