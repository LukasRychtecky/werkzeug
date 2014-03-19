goog.provide 'wzk.ui.ac.ExtSelectboxStorageHandler'

goog.require 'goog.events.EventType'

class wzk.ui.ac.ExtSelectboxStorageHandler

  ###*
    @param {HTMLSelectElement} select
    @param {wzk.ui.ac.ExtSelectboxStorage} storage
  ###
  constructor: (@select, @storage) ->

  ###*
    @param {Array.<wzk.resource.Model>} data
    @param {wzk.ui.TagContainer} cont
    @param {Object=} customRenderer
  ###
  load: (data, cont, customRenderer) ->
    @storage.load(data, cont, customRenderer)
    @hangListener(cont)

  ###*
    @param {wzk.ui.TagContainer} cont
  ###
  store: (cont) ->
    @storage.store(cont)

  ###*
    @param {wzk.ui.Tag} tag
  ###
  remove: (tag) ->
    model = (`/** @type {wzk.resource.Model} */`) tag.getModel()
    @storage.remove model

  ###*
    @protected
  ###
  hangListener: (cont) ->
    goog.events.listen @select.form, goog.events.EventType.SUBMIT, (e) =>
      @store(cont)
