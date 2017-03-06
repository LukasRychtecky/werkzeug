Werkzeug
========

Client side components base on Google Closure. Lot of UI component are base on Closure components, or use Closure
components internally.

[![Build Status](https://travis-ci.org/LukasRychtecky/werkzeug.svg?branch=master)](https://travis-ci.org/LukasRychtecky/werkzeug)


UI components
-------------

* [wzk.ui.Button](wzk/ui/Button.coffee)
  provides basic button functionality with default wzk.ui.ButtonRenderer.

* [wzk.ui.ClearableInput](wzk/ui/ClearableInput.coffee)
  a HTML input field with a clear icon (remove its value)

* [wzk.ui.CloseIcon](wzk/ui/CloseIcon.coffee)
  a component that is rendered as a close/remove icon

* [wzk.ui.Flash](wzk/ui/Flash.coffee)
  renders application messages with fadeout and a closing icon

* [wzk.ui.Input](wzk/ui/Input.coffee)
  a HTML input field a default [wzk.ui.InputRenderer](wzk.ui.InputRenderer)

* [wzk.ui.Link](wzk/ui/Link.coffee)
  a HTML anchor with a default [wzk.ui.LinkRenderer](wzk.ui.LinkRenderer)

* [wzk.ui.TagContainer](wzk/ui/TagContainer.coffee)
  a container of [wzk.ui.Tag](wzk/ui/Tag.coffee) component. Provides adding/removing ability with a remove icon etc.

* [wzk.ui.ac.SelectAutoComplete](wzk/ui/ac/SelectAutoComplete.coffee)
  decorates HTML Select element and builds auto complete from it. Could be decorated with an image. It should be used
  with select-one.

* [wzk.ui.ac.ExtSelectbox](wzk/ui/ac/ExtSelectBox.coffee)
  decorates HTML Select element and builds auto complete from it. Could be decorated with an image. It should be used
  with select-many.

* [wzk.ui.dialog.Dialog](wzk/ui/dialog/Dialog.coffee)
  extended goog.ui.Dialog component that is rendered as Bootstrap dialog.

* [wzk.ui.dialog.Confirm](wzk/ui/dialog/Confirm.coffee)
  a confirm dialog with prepared buttons, rendered as Bootstrap dialog.

* [wzk.ui.form.AjaxForm](wzk/ui/form/AjaxForm.coffee)
  decorates a HTML form and send it via a XHR request.

* [wzk.ui.form.Checbox](wzk/ui/form/Checkbox.coffee)
  a HTML checkbox element.

* [wzk.ui.form.MirrorInput](wzk/ui/form/MirrorInput.coffee)
  a component that watches a given HTML input and copies its value to itself by key-up.

* [wzk.ui.form.RemoveButton](wzk/ui/form/RemoteButton.coffee)
  a HTML button that sends data via a XHR request. It takes values from given inputs and adds them as a requests
  parameters.

* [wzk.ui.form.RestForm](wzk/ui/form/RestForm.coffee)
  decorates a HTML form and send it via a XHR request but as a REST request (json data).

* [wzk.ui.form.Select](wzk/ui/form/Select.coffee)
  a HTML select element.

* [wzk.ui.form.Textarea](wzk/ui/form/Textarea.coffee)
  a HTML textarea element.

* [wzk.ui.grid.Grid](wzk/ui/grid/Grid.coffee)
  a HTML table elements that provides paging, filtering, sorting and it uses REST API for as a connection with a server

* [wzk.ui.inlineform.DynamicForm](wzk/ui/inlineform/DynamicForm.coffee)
  decorates Django's inline forms and adds dynamic ability to add or delete an item

* [wzk.ui.tab.Tabs](wzk/ui/tab/Tabs.coffee)
  decorates HTML elements and adds tabs behaviour

Independent components
----------------------

Werkzeug provides an architecture for independent components. Basic idea is calling one function from HTML template
and register components via CSS3 selector. Werkzeug provides [wzk.app.App](wzk/app/App.coffee) class. Every component
is registered via __on__ method.


```coffeescript
app = wzk.app.buildApp()
app.on '.my-class', (element, dom, xhrFactory) ->
  # do stuff
```

Where:

* __element__ is a current HTML element matched by __selector__
* __dom__ is a [wzk.dom.Dom](wzk/dom/Dom.coffee) instance
* __xhrFactory__ is a [wzk.net.XhrFactory](wzk/net/XhrFactory.coffee) instance

Every registered component is loaded asynchronously and independently to others. If the component fails (throws
an exception etc.) occured errors are handled automatically and it does not block other components.


[wzk.net.XhrFactory](wzk/net/XhrFactory.coffee) by default shows a loading message via
[wzk.net.FlashMiddleware](wzk/net/Middleware.coffee) when a XHR is in progress.


The application structure follows:

* start.coffee
* app/base.coffee
* index.html

A whole example could be (start.coffee):

```coffeescript
goog.require 'app'

app.start = (win, msgs) ->

  flash = wzk.ui.buildFlash win.document # decorates or builds Flash component
  app._app.registerStandardComponents flash # registers standard UI components from Werkzeug
  app._app.run win, flash, msgs # runs the application

# ensure the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start
```

And app/base.coffee file:

```coffeescript
goog.provide 'app'

goog.require 'wzk.app'

app._app = wzk.app.buildApp()
```

index.html

```html
<html>
<head><title>Werkzeug</title></head>
<body>
<script type="text/javascript">
app.start(window, {error: 'Internal error occurred, sorry.', loading: 'Loading...'});
</body>
</html>
```

[wzk.app.App.registerStandardComponents](wzk/app/App.coffee) registers follow components:
* flash messages
* UI grids
* remote button for AJAX buttons
* AJAX forms
* autocomplete components
* dynamic inline forms
* rich tooltips
* Bootstrap navbar-toggle buttons
* snippet loaders
* related object lookup buttons
* more details [wzk.app.App](wzk/app/App.coffee)

Demos
-----

See demos in `wzk-demo/index.html.

Run demos via `grunt --gruntfile wzk-demo/Gruntfile.coffee` and `wzk-demo/index.html` in a browser.
