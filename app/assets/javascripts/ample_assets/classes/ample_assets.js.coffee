class window.AmpleAssets

  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()

  init: ->
    @options.onInit()
    @setup()
    @pages()
    @events()

  set_options: (opts) ->
    ref = this
    default_options = 
      debug: false
      expanded: true
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
      panels_options:
        debug: false
        width: 950
        height: 100
        orientation: 'vertical'
        key_orientation: 'horizontal'
        keyboard_nav: true
        auto: false
        parent: 'div'
        children: 'div.page'
      pages: [
        { id: 'recent-assets', title: 'Recently Viewed' }
        { id: 'image-assets', title: 'Images' }
        { id: 'document-assets', title: 'Documents' }
      ]
    
    @loaded = false
    @options = default_options
    for k of opts
      @options[k] = opts[k]

  log: (msg) ->
    console.log "ample_assets.log: #{msg}" if @options.debug

  setup: ->
    id = @options.id
    layout = Mustache.to_html(@tpl('layout'),{ id: id, pages: @get_pages(), tabs: @get_pages('tab') })
    @handle = Mustache.to_html(@tpl('handle'),{ id: id, title: @options.handle_text })
    html = $(layout).prepend(@handle)
    $('body').append html
    @style()
    @slide(0) if @options.expanded

  style: ->
    $("##{@options.id} .container").css('height',200)
    if @options.expanded
      $("##{@options.id}").css({height:@options.expanded_height});

  pages: -> 
    ref = this
    tabs = $("##{@options.id} a.tab")
    
    $("##{@options.id} .pages").amplePanels(@options.panels_options).bind 'slide', (e,d) ->
      tabs.removeClass('on')
      $(tabs[d]).addClass('on')
      ref.slide(d)
    
    $.each tabs, (idx, el) ->
      $(this).addClass('on') if idx == 0
      $(el).click ->
        tabs.removeClass('on')
        $(this).addClass('on')
        $("##{ref.options.id} .pages").amplePanels('goto', idx)

  get_pages: (tpl = 'page') ->
    ref = this
    html = ''
    $.each @options.pages, (idx,el) -> 
      html += Mustache.to_html ref.tpl(tpl), el
    html

  toggle: ->
    ref = this
    el = $("##{@options.id}")
    if @options.expanded 
      @options.expanded = false
      el.animate {height: @options.collapsed_height}, "fast", ->
        ref.collapse()
        ref.options.onCollapse()
    else
      @options.expanded = true
      el.animate {height: @options.expanded_height}, "fast", ->
        ref.expand()
        ref.options.onExpand()
        ref.slide(0)

  load: (i) ->
    @log "load(#{i})"
    ref = this
    if @options.pages[i]['url']
      $.get @options.pages[i]['url'], (d,r) ->
        ref.options.pages[i]['loaded'] = true 
        $("##{ref.options.id} .pages .page:nth-child(#{(i+1)})").html(d)
        
    else
      @log "Couldn't load page because there was no url."

  already_loaded: (i) ->
    typeof @options.pages[i]['loaded'] == 'boolean' && @options.pages[i]['loaded']

  slide: (i) ->
    @log "slide(#{i})"
    @load(i) unless @already_loaded(i)

  collapse: ->
    $("##{@options.id} .pages").amplePanels('disable')

  expand: ->
    $("##{@options.id} .pages").amplePanels('enable')

  events: ->
    ref = this
    $("##{@options.id}-handle").live 'click', ->
      ref.toggle()

  tpl: (view) ->
    @tpls()[view]

  tpls: ->
    layout: '
    <div id="{{ id }}"><div class="background">
      <div class="container">
        <div id="{{ id }}-tabs" class="tabs">{{{ tabs }}}</div>
        <div id="{{ id }}-pages" class="pages">{{{ pages }}}</div>
      </div></div>
    </div>'
    handle: '<a href="#" id="{{ id }}-handle" class="handle">{{ title }}</a>'
    tab: '<a href="#" data-role="{{ id }}" class="tab">{{ title }}</a>'
    page: '<div id="{{ id }}" class="page"><ul></ul></div>'
