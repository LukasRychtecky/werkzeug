goog.require 'wzk.ui.grid.Grid'
goog.require 'goog.dom.dataset'

class wzk.ui.grid.PaneMode

  ###*
    @enum {string}
  ###
  @SNIPPET:
    CLS: 'snippet-container'
    PARAM: 'content'

  ###*
    @type {string}
  ###
  @PARAM: 'i'

  ###*
    @enum {string}
  ###
  @ATTRS:
    LINK: 'webLink'
    INDEX: 'webLinkI'

  ###*
    @enum {string}
  ###
  @DATA:
    MODE: 'mode'

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
    @loadModel()

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
    @param {wzk.resource.Model} model
  ###
  loadSnippets: (model) =>
    @ss.set wzk.ui.grid.PaneMode.PARAM, model['id']
    A = wzk.ui.grid.PaneMode.ATTRS
    for el in @dom.clss wzk.ui.grid.PaneMode.SNIPPET.CLS
      link = goog.dom.dataset.get el, A.LINK
      url = model['_web_links'][link]
      i = goog.dom.dataset.get el, A.INDEX
      if i?
        url = url[i]
      if url?
        @processSnippet url, el

  ###*
    @protected
    @param {string} url
    @param {Element} el
  ###
  processSnippet: (url, el) ->
    PARAM = wzk.ui.grid.PaneMode.SNIPPET.PARAM
    @client.request url + '?snippet=' + PARAM, 'GET', {}, (json) =>
      if json['snippets']?
        el.innerHTML = json['snippets'][PARAM]
      @reg.process el
