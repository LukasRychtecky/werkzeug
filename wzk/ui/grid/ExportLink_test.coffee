suite 'wzk.ui.grid.ExportLink', ->
  ExportLink = wzk.ui.grid.ExportLink
  Query = wzk.resource.Query

  doc = null
  watcher = null
  param = null
  query = null

  class MockFilterWatcher

    constructor: (@grid, @query) ->

    getGrid: ->
      @grid

    getQuery: ->
      @query


  class Grid

    constructor: (@cols) ->

    getColumns: ->
      @cols


  joinAttrs = (attrs) ->
    ("#{k}='#{v}'" for k, v of attrs).join ''

  buildDom = (attrs) ->
    doc = jsdom """
    <html><head></head>
    <body>
      <a id="export" href="/api/order?state=2&amp;def=2" data-type="csv">Export</a>
      <input #{joinAttrs(attrs)} type="text">
    </body>
    </html>
    """

  buildExportLink = (cols) ->
    buildDom()
    param = new wzk.resource.FilterValue('state', '', '2')
    query = new Query('/api/order').filter(param)
    l = new ExportLink(watcher: new MockFilterWatcher(new Grid(cols), query))
    l.decorate(doc.getElementById('export'))
    l

  test 'Should use a parameter when is default and in columns', ->
    link = buildExportLink ['id', 'state']

    assert.equal link.buildUri(), '/api/order?state=2&_accept=text%2Fcsv&def=2'
    # change state parameter
    param.setValue ''
    query.filter param
    assert.equal link.buildUri(), '/api/order?_accept=text%2Fcsv&def=2'
