class window.AmpleAssets

  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()

  init: ->
    @options.onInit()
    @setup()
    @events()

  set_options: (opts) ->
    @params = 
      expanded: false
    ref = this
    default_options = 
      debug: false
      id: "ample-assets"
      handle_text: 'Assets'
      expanded_height: 150
      collapsed_height: 25
      onInit: ->
        ref.log 'onInit()'
      onExpand: ->
        ref.log 'onExpand()'
      onCollapse: ->
        ref.log 'onCollapse()'
    @options = default_options
    for k of opts
      @options[k] = opts[k]

  log: (msg) ->
    console.log "mobile_pages.log: #{msg}" if @options.debug

  setup: ->
    id = @options.id
    layout = Mustache.to_html(@tpl('layout'),{id: id})
    @handle = Mustache.to_html(@tpl('handle'),{id: id, title: @options.handle_text})
    html = $(layout).prepend(@handle)
    $('body').append html

  toggle: ->
    ref = this
    el = $("##{@options.id}")
    if @params.expanded 
      @params.expanded = false
      el.animate
        height: @options.collapsed_height
      , "fast", ->
        ref.options.onCollapse()
    else
      @params.expanded = true
      el.animate
        height: @options.expanded_height
      , "fast", ->
        ref.options.onExpand()

  events: ->
    ref = this
    $("##{@options.id}-handle").live 'click', ->
      ref.toggle()

  tpl: (view) ->
    tpls = 
      layout: '<div id="{{ id }}"><div class="content"></div><div class="container"></div></div>'
      handle: '<a href="#" id="{{ id }}-handle" class="handle">{{ title }}</a>'
    tpls[view]

