goog.require 'goog.dom.dataset'
goog.require 'wzk.ui.form.ModalForm'
goog.require 'wzk.ui.ac'

class wzk.ui.form.RelatedObjectLookup

  constructor: (@dom, @client) ->

  ###*
    @protected
    @param {string} attr
    @return {string}
  ###
  data: (attr) ->
    String goog.dom.dataset.get(@el, attr)

  decorate: (@el) ->
    @modal = new wzk.ui.form.ModalForm @dom, @client, @data('url'), @data('form')
    @modal.setTitle @el.title if @el.title

    @related = @dom.getElement @data('related')
    if @related and goog.dom.classes.has @related, 'fulltext-search'
      #if @related and goog.dom.classes.has @related, 'related-fulltext-search'
      @related = (`/** @type {HTMLSelectElement} */`) @related
      @ac = wzk.ui.ac.buildSelectAutoCompleteNative @related, @dom
      @modal.listen wzk.ui.form.ModalForm.EventType.SUCCESS_CLOSE, @handleSave

    goog.events.listen @el, goog.events.EventType.CLICK, @handleOpen

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSave: (e) =>
    model = new wzk.resource.Model e.target['obj']
    @ac.addModel model
    @ac.setDefaultValue model

  ###*
    @protected
  ###
  handleOpen: =>
    @modal.open()

