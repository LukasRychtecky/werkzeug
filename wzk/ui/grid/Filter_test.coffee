suite 'wzk.ui.grid.Filter', ->
  Filter = wzk.ui.grid.Filter

  doc = null

  joinAttrs = (attrs) ->
    ("#{k}='#{v}'" for k, v of attrs).join ''

  buildDom = (attrs) ->
    doc = jsdom """
    <html><head></head>
    <body>
      <input #{joinAttrs(attrs)} type="text">
    </body>
    </html>
    """

  buildFilter = ->
    dom = new wzk.dom.Dom(doc)
    filter = new Filter dom, dom.one('input')

  test 'Should parse a parameter name and an operator', ->
    attrs =
      'data-filter': 'order__ext_variable_symbol__icontains'
      'name': 'filter__order__ext_variable_symbol__icontains'
    buildDom attrs

    filter = buildFilter()
    assert.equal 'order__ext_variable_symbol', filter.getName()
    assert.equal 'icontains', filter.getOperator()
    assert.equal 'order__ext_variable_symbol__icontains', filter.getFilter()

  test 'Should parse a paramter name without an operator', ->
    attrs =
      'data-filter': 'eshop'
      'name': 'filter__eshop'
    buildDom attrs

    filter = buildFilter()
    assert.equal 'eshop', filter.getName()
    assert.equal '', filter.getOperator()
    assert.equal 'eshop', filter.getFilter()
