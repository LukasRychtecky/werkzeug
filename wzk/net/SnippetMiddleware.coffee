goog.require 'goog.dom.dataset'

class wzk.net.SnippetMiddleware

  ###*
    @enum {string}
  ###
  @DATA:
    SNIPPET: 'snippet'
    TYPE: 'snippetType'
    LOADER: 'snippetLoader'

  ###*
    @enum {string}
  ###
  @SELECTOR:
    SNIPPET: 'data-snippet'
    LOADER: 'data-snippet-loader'

  ###*
    @enum {string}
  ###
  @TYPE:
    REPLACE: 'replace'
    APPEND: 'append'
    PREPEND: 'prepend'

  ###*
    @param {wzk.app.Register} reg
    @param {wzk.dom.Dom} dom
    @param {Object} opts
  ###
  constructor: (@reg, @dom, @opts) ->

  ###*
    @param {Object} res
  ###
  apply: (res) ->
    return unless res['snippets']

    D = wzk.net.SnippetMiddleware.DATA
    S = wzk.net.SnippetMiddleware.SELECTOR

    loaders = {}
    for loader in @dom.all "*[#{S.LOADER}]"
      tokens = String(goog.dom.dataset.get(loader, D.LOADER)).split ' '
      loaders[name] = loader for name in tokens

    for name, snip of res['snippets']

      if loaders[name]?
        @process loaders[name], snip

      el = @dom.one "*[#{S.SNIPPET}=#{name}]"
      if el?
        @process el, snip

  ###*
    @protected
    @param {Element} el
    @param {string} snippet
  ###
  process: (el, snippet) ->
    type = goog.dom.dataset.get(el, wzk.net.SnippetMiddleware.DATA.TYPE) ? wzk.net.SnippetMiddleware.TYPE.REPLACE

    method = switch type
      when wzk.net.SnippetMiddleware.TYPE.REPLACE then @replace
      when wzk.net.SnippetMiddleware.TYPE.APPEND then @append
      when wzk.net.SnippetMiddleware.TYPE.PREPEND then @prepend

    goog.bind(method, @, snippet, el)()

  ###*
    @protected
    @param {string} html
    @param {Element} el
  ###
  replace: (html, el) ->
    el.innerHTML = html
    @reg.process el

  ###*
    @protected
    @param {string} html
    @param {Element} el
  ###
  append: (html, el) ->
    newEl = @dom.htmlToDocumentFragment html
    el.appendChild newEl
    @reg.process newEl

  ###*
    @protected
    @param {string} html
    @param {Element} el
  ###
  prepend: (html, el) ->
    newEl = @dom.htmlToDocumentFragment html
    @dom.prependChild el, (`/** @type {Element} */`) newEl
    @reg.process newEl
