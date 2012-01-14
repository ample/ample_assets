class window.AmpleAssets
  
  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()
  
  init: ->
    @options.onInit()
    @setup()
    @events()
  
  set_options: (opts) ->
    @current = 0
    @keys_enabled = true
    @reloading = false
    ref = this
    default_options = 
      debug: true
      expanded: false
      id: "ample-assets"
      handle_text: 'Assets'
      expanded_height: 215
      collapsed_height: 35
      base_url: '/ample_assets'
      search_url: '/files/search'
      thumb_url: '/files/thumbs'
      show_url: '/files/{{ id }}'
      touch_url: '/files/{{ id }}/touch'
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
        key_orientation: 'vertical'
        keyboard_nav: true
        auto: false
        parent: 'div'
        children: 'div.page'
      pages_options:
        interval: 5000
        width: 81 
        height: 81
        enabled: true
        distance: 10
        auto: false
        orientation: 'horizontal'
        key_orientation: 'horizontal'
        per_page: 10
      pages: [
        { 
          id: 'recent-assets', 
          title: 'Recently Viewed',
          url: '',
          panels: false
        }
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
    @drag_drop()
    @search()
    @goto(0) if @options.expanded
    $('body').bind 'ample_uploadify.complete', =>
      @reload(0)
  
  style: ->
    @loading = $("##{@options.id}-tabs span.asset-loading")
    $("##{@options.id} .container").css('height',200)
    if @options.expanded
      $("##{@options.id}").css({height:@options.expanded_height});
  
  reload: (i) ->
    @log "reload(#{i})"
    @reloading = true
    @empty(i)
    @options.pages[i]['loaded'] = false
    @options.pages[i]['pages_loaded'] = 0
    $(@options.pages[i]['panel_selector']).amplePanels('goto', 0)
    @goto(i)
    @enable_panel(i)
  
  empty: (i) ->
    @log "empty(#{i})"
    selector = "##{@options.id} .pages .page:nth-child(#{(i+1)})" 
    selector += " ul" if @options.pages[i]['panels']
    $(selector).empty()
  
  goto: (i) ->
    @log "goto(#{i})"
    @current = i
    @show(i)
    @disable_panels()
    @activate(i)
    @load(i) unless @already_loaded(i)
    @enable_panel(i) if @already_loaded(i)
  
  show: (i) ->
    $("##{@options.id} .pages .page").hide()
    $("##{@options.id} .pages .page:nth-child(#{i+1})").show()
  
  drag_drop: ->
    base_url = @options.base_url
    thumb_url = @options.thumb_url
    
    $(".draggable").liveDraggable
      appendTo: "body"
      helper: "clone"
    
    $("textarea").droppable
      activeClass: "asset-notice"
      hoverClass: "asset-success"
      drop: (event, ui) ->
        geometry = if $(ui.draggable).attr("orientation") == 'portrait' then 'x300>' else '480x>'
        uid = $(ui.draggable).attr("data-uid")
        url = encodeURI "#{base_url}#{thumb_url}/#{geometry}?uid=#{uid}"
        textile = "!#{url}!"
        html = "<img src=\"#{url}\" />"
        $(this).insertAtCaret (if $(this).hasClass('textile') then textile else html)
    
    $(".droppable").droppable
      activeClass: "asset-notice"
      hoverClass: "asset-success"
      drop: (event, ui) ->
        $(this).html ui.draggable.clone()
        asset_id = $(ui.draggable).attr("id").split("-")[1]
        $(this).parent().children().first().val asset_id
        $(this).parent().find('a.asset-remove').removeClass('hide').show()
  
  activate: (i) ->
    @log "activate(#{i})"
    tabs = $("##{@options.id} a.tab")
    tabs.removeClass('on')
    tabs.eq(i).addClass('on')
  
  next: ->
    if @current < @options.pages.length - 1
      @log "next()"
      @current += 1
      @goto(@current)
  
  previous: ->
    unless @current == 0
      @log "previous()"
      @current -= 1
      @goto(@current)
  
  get_pages: (tpl = 'page') ->
    html = ''
    $.each @options.pages, (idx,el) => 
      el['classes'] = 'first-child' if idx == 0
      html += Mustache.to_html @tpl(tpl), el
    html
  
  toggle: ->
    el = $("##{@options.id}")
    if @options.expanded 
      @options.expanded = false
      $('body').animate {'padding-bottom': 0}, "fast"
      el.animate {height: @options.collapsed_height}, "fast", =>
        @collapse()
        @options.onCollapse()
    else
      @options.expanded = true
      $('body').animate {'padding-bottom': @options.expanded_height}, "fast"
      el.animate {height: @options.expanded_height}, "fast", =>
        @expand()
        @options.onExpand()
  
  load: (i) ->
    @log "load(#{i})"
    ref = this
    load_next_page = true unless @options.pages[i]['last_request_empty']
    load_next_page = true if @reloading

    if @options.pages[i]['url'] && load_next_page
      @loading.show()
      url = @next_page_url(i)
      data_type = @options.pages[i]['data_type'] if @options.pages[i]['data_type']
      $.get url, (response, xhr) ->
        ref.loading.hide()
        ref.options.pages[i]['loaded'] = true 
        if $.trim(response) == '' || response.length == 0
          ref.options.pages[i]['last_request_empty'] = true
          console.log ">>> #{ref.reloading}"
          ref.load_empty(i) if ref.reloading || !ref.options.pages[i]['panel_selector']
        else 
          switch data_type
            when "json"
              ref.load_json i, response
            when "html"
            else
              ref.load_html i, response
      , data_type
    else
      @log "ERROR --> Couldn't load page because there was no url" unless @options.pages[i]['last_request_empty']
  
  load_empty: (i) ->
    @log "load_empty(#{i})"
    empty = Mustache.to_html(@tpl('empty'))
    @load_html(i, empty)
    @loading.hide()
    $('li.empty').css('width',$('.ampn').first().width())
    $('li.empty a').click =>
      @goto(@options.pages.length-2)
  
  load_html: (i, response) ->
    @log "load(#{i}) html"
    selector = "##{@options.id} .pages .page:nth-child(#{(i+1)})" 
    selector += " ul" if @options.pages[i]['panels']
    $(selector).html(response)
    @panels(i)
  
  load_json: (i, response) ->
    @log "load(#{i}) json"
    panels_loaded = if @options.pages[i]['panel_selector'] then true else false
    ref = this
    selector = "##{@options.id} .pages .page:nth-child(#{(i+1)}) ul" 
    $.each response, (j,el) ->
      link = ref.build(el)
      li = $('<li class="file"></li>').append(link)
      if panels_loaded
        $(selector).amplePanels('append', li)
      else
        $(selector).append(li)
      ref.load_img(li.find('a'), el.sizes.tn)
    @panels(i) unless panels_loaded
    if @reloading
      @reloading = false
      @controls() 
  
  load_results: (response) ->
    @log "load_results()"
    $.each response, (j,el) =>
      link = @build(el)
      li = $('<li class="file"></li>').append(link)
      $("#asset-results ul").amplePanels('append', li)
      @load_img(link, el.sizes.tn)
    @active_panel = $("#asset-results ul")
    @show(@options.pages.length-1)
    @controls()
  
  build: (el) ->
    ref = this
    show_url = Mustache.to_html @options.show_url, { id: el.id }
    link = $("<a href=\"#{@options.base_url}#{show_url}\" draggable=\"true\"></a>")
      .attr('id',"file-#{el.id}")
      .attr('data-uid',"#{el.uid}")
      .attr('data-orientation',el.orientation)
      .addClass('draggable')
    link.addClass('document') if el.document == 'true'
    link.click ->
      ref.modal_open(el)
      false
    link
  
  modal_open: (data) ->
    @modal_active = true
    if data.document == 'true'
      html = Mustache.to_html(@tpl('pdf'),{ filename: data.uid })
      $.facebox("<div class=\"asset-detail\">#{html}</div>")
      myPDF = new PDFObject(
        url: data.url
        pdfOpenParams:
          view: "Fit"
      ).embed("pdf")
    else
      geometry = if data.orientation == 'portrait' then 'x300>' else '480x>'
      url = "#{@options.base_url}#{@options.thumb_url}/#{geometry}?uid=#{data.uid}"
      html = Mustache.to_html(@tpl('show'),{ filename: data.uid, src: url, orientation: data.orientation })
      console.log html
      $.facebox("<div class=\"asset-detail\">#{html}</div>")
    @touch(data)
  
  load_img: (el,src) ->
    img = new Image()
    $(img).load(->
      $(this).hide()
      $(el).html this
      $(this).fadeIn()
    ).attr src: src
  
  next_page_url: (i) ->
    @options.pages[i]['pages_loaded'] = 0 unless @options.pages[i]['pages_loaded']
    @options.pages[i]['pages_loaded'] += 1
    "#{@options.pages[i]['url']}?page=#{@options.pages[i]['pages_loaded']}"
  
  touch: (el) ->
    @log "touch()"
    touch_url = Mustache.to_html @options.touch_url, { id: el.id }
    $.post "#{@options.base_url}#{touch_url}"
  
  panels: (i) ->
    ref = this
    if @options.pages[i]['panels']
      @log "panels(#{i})"
      el = "##{@options.id} .pages .page:nth-child(#{(i+1)}) ul"
      @options.pages[i]['panel_selector'] = el
      @active_panel = el
      @options.pages[i][''] = $(el).attr('id',"#{@options.pages[i]['id']}-panel")
      $(el).parent().addClass('panels')
      @controls()
      $(el).amplePanels(@options.pages_options)
        .bind 'slide_horizontal', (e,d,dir) ->
          ref.load(i) if dir == 'next'
  
  disable_panels: ->
    @log "disable_panels()"
    ref = this
    @controls(false)
    $.each @options.pages, (i,el) ->
      $(ref.options.pages[i]['panel_selector']).amplePanels('disable') if ref.options.pages[i]['panel_selector']
  
  enable_panel: (i) ->  
    @log "enable_panel(#{i})"
    if @options.pages[i]['panel_selector']
      @active_panel = @options.pages[i]['panel_selector']
      $(@options.pages[i]['panel_selector']).amplePanels('enable') 
      @controls()
  
  controls: (display=true) ->
    @log "controls(#{display})"
    display = false if $(@active_panel).find('li').length < @options.pages_options.per_page
    switch display
      when true
        $('nav.controls').show()
      when false
        $('nav.controls').hide()
  
  already_loaded: (i) ->
    typeof @options.pages[i]['loaded'] == 'boolean' && @options.pages[i]['loaded']
  
  remove: (el) ->
    parent = $(el).parent()
    parent.find('.droppable').empty().html('<span>Drag Asset Here</span>')
    parent.find('input').val('')
    $(el).hide()
  
  collapse: ->
    @disable_panels()
  
  expand: ->
    @goto(@current)
  
  events: ->
    @modal_events()
    @global_events()
    @field_events()
    @drop_events()
    @drag_events()
    @reload_events()
    ref = this
    $("a.asset-remove").live 'click', ->
      ref.remove(this)
      false
    $("##{@options.id}-handle").live 'click', =>
      @toggle()
      false
    @key_down()
    tabs = $("##{@options.id} a.tab")
    ref = this
    $.each tabs, (idx, el) ->
      $(this).addClass('on') if idx == 0
      $(el).click ->
        ref.goto(idx)
        false
  
  global_events: ->
    $('a.global.next').click =>
      $(@active_panel).amplePanels('next')
      
    $('a.global.previous').click =>
      $(@active_panel).amplePanels('previous')
  
  drag_events: ->
    @log "drag_events()"
    # TODO: kill key events during drag?
  
  drop_events: ->
    ref = this
    $('.asset-drop .droppable a').live 'click', ->
      id = $(this).attr("href")
      $.get $(this).attr("href"), (response) ->
        ref.modal_open(response)
      , 'json'
      false
  
  field_events: ->
    @log "field_events()"
    $('textarea, input').live 'blur', =>
      @keys_enabled = true
    $('textarea, input').live 'focus', =>
      @keys_enabled = false
  
  reload_events: ->
    @log "reload_events()"
    reload = $('<a href="#" class="assets-reload"><span></span></a>')
    reload.appendTo('.asset-refresh').click (e) =>
      @reload(@current)
    
  modal_events: ->
    @modal_active = false
    $(document).bind 'afterClose.facebox', =>
      @keys_enabled = true
      @modal_active = false
    $(document).bind 'loading.facebox', =>
      @keys_enabled = false
      @modal_active = true
  
  search: ->
    @log 'search_events()'
    search_url = "#{@options.base_url}#{@options.search_url}"
    i = ($("##{@options.id} .pages .page").length - 1)
    ref = this
    $('#asset-results ul').attr('id','assets-result-list').amplePanels(@options.pages_options)
    @options.pages[i] = { loaded: true }
    $('#asset-search').bind 'change', ->
      $("#asset-results ul").amplePanels('empty')
      $.post search_url, $(this).serialize(), (response) ->
        ref.load_results(response)
        $('.asset-results').show()
        ref.activate(i)
      , 'json'
  
  key_down: ->
    ref = this
    previous = 37
    next = 39
    up = 38
    down = 40
    escape = 27
    
    $(document).keyup (e) =>
      return unless @keys_enabled
      switch e.keyCode
        when escape
          @toggle() unless @modal_active
      e.stopPropagation();
    
    $(document).keydown (e) =>
      return unless @keys_enabled
      if @active_panel
        switch e.keyCode
          when previous
            $(@active_panel).amplePanels('previous')
          when next
            $(@active_panel).amplePanels('next')
          when up
            @previous()
          when down
            @next()
      e.stopPropagation();
  
  tpl: (view) ->
    @tpls()[view]
  
  tpls: ->
    layout: '
    <div id="{{ id }}"><div class="background">
      <div class="container">
        <div id="{{ id }}-tabs" class="tabs">
          <div class="asset-refresh"></div>
          <div class="asset-search">
            <input type="text" id="asset-search" name="q" placeholder="Enter keywords..." />
            <label for="asset-search">Search</label>
          </div>
          {{{ tabs }}}
          <a href="#" data-role="asset-search-results" class="tab asset-results">Results</a>
          <span class="asset-loading"></span>
        </div>
        <div id="{{ id }}-pages" class="pages">
          {{{ pages }}}
          <div id="asset-results" class="page panels">
            <ul></ul>
          </div>
        </div>
        <nav class="controls">
          <a href="#" class="global previous">Previous</a>
          <a href="#" class="global next">Next</a>
        </nav>
      </div></div>
    </div>'
    handle: '<a href="#" id="{{ id }}-handle" class="handle">{{ title }}</a>'
    tab: '<a href="#" data-role="{{ id }}" class="tab {{ classes }}">{{ title }}</a>'
    page: '
    <div id="{{ id }}" class="page">
      <ul></ul>
    </div>'
    show: '
    <div class="asset-detail">
      <div class="asset-media {{ orientation }}">
        <img src="{{ src }}" />
      </div>
      <h3>{{ filename }}</h3>
    </div>'
    pdf: '
    <div class="asset-detail">
      <div id="pdf" class="asset-media"></div>
      <h3>{{ filename }}</h3>
    </div>'
    empty: '<li class="empty">Oops. There\'s nothing here. You should <a href="#">upload something</a>.</li>'
  

jQuery.fn.liveDraggable = (opts) ->
  @live "mouseover", ->
    $(this).data("init", true).draggable opts  unless $(this).data("init")
    

jQuery.fn.insertAtCaret = (value) ->
  @each (i) ->
    if document.selection
      @focus()
      sel = document.selection.createRange()
      sel.text = value
      @focus()
    else if @selectionStart or @selectionStart is "0"
      startPos = @selectionStart
      endPos = @selectionEnd
      scrollTop = @scrollTop
      @value = @value.substring(0, startPos) + value + @value.substring(endPos, @value.length)
      @focus()
      @selectionStart = startPos + value.length
      @selectionEnd = startPos + value.length
      @scrollTop = scrollTop
    else
      @value += value
      @focus()

