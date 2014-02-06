goog.provide 'wzk.ui.inlineform.ConfigHandler'

goog.require 'goog.string'

class wzk.ui.inlineform.ConfigHandler

  ###*
    @param {Element} fieldset
  ###
  constructor: (@fieldset) ->
    @formNum = 0
    @MAX_FORMS = 1000
    @INIT_FORMS = 0
    @formNumField = null
    @maxNumField = null

  load: ->
    for field in @fieldset.querySelectorAll('input[type=hidden]')
      if goog.string.endsWith(field.name, 'TOTAL_FORMS')
        @formNum = @parseValue(field)
        @formNumField = field
      else if goog.string.endsWith(field.name, 'MAX_NUM_FORMS')
        @MAX_FORMS = @parseValue(field)
        @maxNumField = field
      else if goog.string.endsWith(field.name, 'INITIAL_FORMS')
        @INIT_FORMS = @parseValue(field)
        @maxNumField = field

  store: (forms) ->
    @formNumField?.value = forms

  ###*
    @protected
  ###
  parseValue: (field) ->
    parseInt(field.value, 10)
