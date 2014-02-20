class wzk.ui.InputSearchRenderer extends wzk.ui.InputRenderer

  constructor: ->
    super()

  ###*
    @override
  ###
  createDom: (input) ->
    dom = input.getDomHelper()
    wrapper = dom.el 'div', 'input-search-wrapper'
    classes = @getClassNames(input)
    classes.push 'form-control'
    field = dom.el('input',
      'type': 'text'
      'class': classes.join(' ')
    )
    wrapper.appendChild(field)
    wrapper.appendChild dom.el 'div', 'search-icon'
    wrapper

goog.addSingletonGetter wzk.ui.InputSearchRenderer
