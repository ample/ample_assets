# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleAssetsToolbar extends CoffeeCup
  
  default_options: 
    debug: false
    expanded: false
    id: "ample-assets"
    handle_text: 'Assets'
    expanded_height: 180
    collapsed_height: 0
    base_url: '/ample_assets'
    search_url: '/files/search'
    thumb_url: '/files/thumbs'
    show_url: '/files/{{ id }}'
    touch_url: '/files/{{ id }}/touch'
    gravity_url: '/files/{{ id }}/gravity'
    onInit: ->
    onExpand: ->
    onCollapse: ->
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
  
  # Initialize product toolbar and drop targets. 
  init: ->
    @options.onInit()
    super
    @setup()
    @events()
  
  # Setup global parameters & class options. 
  set_options: (opts) ->
    @current = 0
    @keys_enabled = true
    @reloading = false
    @searching = false
    @loaded = false
    super
  
  # Build structure and stylize layout of toolbar, setup drag, drop and search logic.
  # Opens first tab if toolbar is expanded on init.
  setup: ->
    id = @options.id
    layout = Mustache.to_html(@tpl('layout'),{ id: id, pages: @get_pages(), tabs: @get_pages('tab') })
    @handle = Mustache.to_html(@tpl('handle'),{ id: id, title: @options.handle_text })
    html = $(layout)
    $('body').append(html).append(@handle)
    @style()
    @drag_drop()
    @search()
    @goto(0) if @options.expanded
  
  # Set initial styles on toolbar elements.
  style: ->
    handle_opts = 
      position: 'absolute'
      bottom: 0
      right: 0
    $("##{@options.id}-handle").css(handle_opts)
    
    @loading = $("##{@options.id}-tabs span.asset-loading")
    $("##{@options.id} .container").css('height',200)
    if @options.expanded
      $("##{@options.id}").css({height:@options.expanded_height});
  
  # Reloads tab identified by `i`
  reload: (i) ->
    @log "reload(#{i})"
    @reloading = true
    if i < @options.pages.length - 1 
      @empty(i)
      @options.pages[i]['loaded'] = false
      @options.pages[i]['pages_loaded'] = false
      @options.pages[i]['last_request_empty'] = false
      $(@options.pages[i]['panel_selector']).amplePanels('goto', 0)
      @goto(i)
      @enable_panel(i)
  
  # Empties the contents of the page identified by `i`
  empty: (i) ->
    @log "empty(#{i})"
    selector = "##{@options.id} .pages .page:nth-child(#{(i+1)})" 
    selector += " ul" if @options.pages[i]['panels']
    $(selector).empty()
  
  # Hide and deactivate current page, load next page identified by `i`
  goto: (i) ->
    @log "goto(#{i})"
    @show(i)
    @disable_panels()
    @activate(i)
    @load(i) unless @already_loaded(i)
    @enable_panel(i) if @already_loaded(i)
  
  # Hide all pages, show page identified by `i`
  show: (i) ->
    $("##{@options.id} .pages .page").hide()
    $("##{@options.id} .pages .page:nth-child(#{i+1}), ##{@options.id} .pages .page:nth-child(#{i+1}) ul").show()
  
  # Implement drag & droppable instances, with appropriate callbacks.
  drag_drop: ->
    base_url = @options.base_url
    thumb_url = @options.thumb_url
    ref = this
    
    # Note the use of liveDraggable here. See extended plugin at the bottom of this file.
    $(".draggable").liveDraggable
      appendTo: "body"
      helper: "clone"
      start: ->
        $('div.ui-droppable, textarea.ui-droppable').addClass('asset-drop-target')
      stop: ->
        $('div.ui-droppable, textarea.ui-droppable').removeClass('asset-drop-target')
    
    $("textarea").droppable
      activeClass: "asset-notice"
      hoverClass: "asset-success"
      accept: ".draggable"
      drop: (event, ui) ->
        unless $(ui.helper).data('role') == 'gravity'
          ref.target_textarea = this
          ref.resize_modal(ui.draggable)
    
    $(".droppable").droppable
      activeClass: "asset-notice"
      hoverClass: "asset-success"
      accept: ".draggable"
      drop: (event, ui) ->
        unless $(ui.helper).data('role') == 'gravity'
          $(this).html ui.draggable.clone()
          asset_id = $(ui.draggable).attr("id").split("-")[1]
          $(this).parent().children().first().val asset_id
          $(this).parent().find('a.asset-remove').removeClass('hide').show()
  
  # Build html for modal windows wherein users can resize the asset's dimensions & geometry.
  # Executes when dropping a file into a textarea. The first argument is the response 
  # from the droppable callbacks defined above.
  resize_modal: (el) ->
    uid = $(el).attr("data-uid")
    size = $(el).attr("data-size")
    orientation = $(el).attr("data-orientation")
    base_url = @options.base_url
    thumb_url = @options.thumb_url
    geometry = '100x>'
    opts = 
      src: "#{base_url}#{thumb_url}/#{geometry}?uid=#{uid}"
      orientation: orientation
      dimensions: size
      uid: uid
    html = Mustache.to_html(@tpl('drop'), opts)
    $.facebox("<div class=\"asset-detail\">#{html}</div>")
  
  # Removes active state from all tabs, adds it back for tab identified by `i`
  activate: (i) ->
    @log "activate(#{i})"
    @current = i
    tabs = $("##{@options.id} a.tab")
    tabs.removeClass('on')
    tabs.eq(i).addClass('on')
  
  # Highlight & load next tab (right) by incrementing `@current`
  next: ->
    if @current < @options.pages.length - 1
      @log "next()"
      @current += 1
      @goto(@current)
  
  # Highlight & load previous tab (left) by decrementing `@current`
  previous: ->
    unless @current == 0
      @log "previous()"
      @current -= 1
      @goto(@current)
  
  # Loops through all pages, generates HTML and returns concatenated string of everything.
  get_pages: (tpl = 'page') ->
    html = ''
    $.each @options.pages, (idx,el) => 
      el['classes'] = 'first-child' if idx == 0
      html += Mustache.to_html @tpl(tpl), el
    html
  
  # Expands and collapses asset toolbar.
  toggle: ->
    el = $("##{@options.id}")
    if @options.expanded 
      @options.expanded = false
      $('body').animate {'padding-bottom': 0}, "fast"
      el.animate {height: @options.collapsed_height}, "fast", =>
        @collapse()
        @options.onCollapse()
        el.trigger('collapse')
    else
      $("##{@options.id}-handle").hide()
      @options.expanded = true
      $('body').animate {'padding-bottom': @options.expanded_height}, "fast"
      el.animate {height: @options.expanded_height}, "fast", =>
        @expand()
        @options.onExpand()
        el.trigger('expand')
  
  # Loads contents of page identified by `i`
  load: (i) ->
    @log "load(#{i})"
    ref = this
    load_next_page = true 
    load_next_page = false if @options.pages[i]['last_request_empty']
    load_next_page = true if @reloading
    
    if @options.pages[i]['url'] && load_next_page
      @loading.show()
      url = @next_page_url(i)
      data_type = @options.pages[i]['data_type'] if @options.pages[i]['data_type']
      $.get url, (response, xhr) ->
        ref.loading.hide()
        ref.options.pages[i]['loaded'] = true 
        # If response is empty, let users know by loading an empty notification.
        if $.trim(response) == '' || response.length == 0
          ref.options.pages[i]['last_request_empty'] = true
          ref.load_empty(i) if ref.reloading || !ref.options.pages[i]['panel_selector']
        else 
          switch data_type
            when "json"
              # Parse json for requests of that type.
              ref.load_json i, response
            when "html"
            else
              # Parse html by default or for requests of that specific type.
              ref.load_html i, response
      , data_type
    else
      # Notify console if we couldn't load a page due to a missing URL.
      @log "ERROR --> Couldn't load page because there was no url" unless @options.pages[i]['last_request_empty']
  
  # For empty requests, insert notification text into page identified by `i`
  load_empty: (i) ->
    @log "load_empty(#{i})"
    empty = Mustache.to_html(@tpl('empty'))
    @load_html(i, empty)
    @loading.hide()
    $('li.empty').css('width',$('.ampn').first().width())
    $('li.empty a').click =>
      @goto(@options.pages.length-2)
  
  # Load html content returned as `response` by XHR request into page identified by `i`
  load_html: (i, response) ->
    @log "load(#{i}) html"
    selector = "##{@options.id} .pages .page:nth-child(#{(i+1)})" 
    selector += " ul" if @options.pages[i]['panels'] || @searching
    $(selector).html(response).show()
    @panels(i)
  
  # Parse `response` as json data and build list-items for each element contained therein.
  # This method assumes page identified by `i` contains an ample_panels instance.
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
    $(selector).show()
    @panels(i) unless panels_loaded
    if @reloading
      @reloading = false
      @controls() 
  
  # Parse `response` from search results as json data. 
  load_results: (response) ->
    @log "load_results()"
    i = @options.pages.length - 1

    if response.length > 0
      # Build list-item for each item returned from search query.
      $.each response, (j,el) =>
        link = @build(el)
        li = $('<li class="file"></li>').append(link)
        $("#asset-results ul").amplePanels('append', li)
        @load_img(link, el.sizes.tn)
    else
      # No results were returned, inject no-results verbiage.
      no_results = Mustache.to_html(@tpl('no_results'))
      @load_html(i, no_results)
      @loading.hide()
      $('li.empty').css('width',$('.ampn').first().width())
      
    @options.pages[i]['panel_selector'] = "#asset-results ul"
    @active_panel = $(@options.pages[i]['panel_selector'])
    @searching = false
    @loading.hide()
    @controls()
  
  # Builds each asset instance with proper attributes. 
  build: (el) ->
    ref = this
    show_url = Mustache.to_html @options.show_url, { id: el.id }
    link = $("<a href=\"#{@options.base_url}#{show_url}\" draggable=\"true\"></a>")
      .attr('id',"file-#{el.id}")
      .attr('data-uid',"#{el.uid}")
      .attr('data-filename',"#{el.filename}")
      .attr('data-gravity', el.gravity)
      .addClass('draggable')
    if el.document == 'true'
      link.addClass('document')
    else
      link.attr('data-orientation',el.orientation)
      link.attr('data-size',el.size)
    link.click ->
      # Open a modal window on any asset instance's click event.
      ref.modal_open(el)
      false
    link
  
  # Opens modal window instance for asset detail. 
  modal_open: (data) ->
    @modal_active = true
    if data.document == 'true'
      # Asset is a document, so lets instantiate PDFObject for viewing inline.
      delete_url = Mustache.to_html @options.show_url, { id: data.id }
      html = Mustache.to_html @tpl('pdf'),
        filename: data.uid, 
        id: data.id,
        delete_url: "#{@options.base_url}#{delete_url}",
        mime_type: data.mime_type,
        url: data.url
      $.facebox("<div class=\"asset-detail\">#{html}</div>")
      myPDF = new PDFObject(
        url: data.url
        pdfOpenParams:
          view: "Fit"
      ).embed("pdf")
    else
      # Asset is an image, lets display it inline, according to its orientation. 
      geometry = if data.orientation == 'portrait' then 'x300>' else '480x>'
      url = "#{@options.base_url}#{@options.thumb_url}/#{geometry}?uid=#{data.uid}"
      delete_url = Mustache.to_html @options.show_url, { id: data.id }
      gravity_url = Mustache.to_html @options.gravity_url, { id: data.id }
      update_url = Mustache.to_html @options.show_url, { id: data.id }
      gravity = $("a[data-uid='#{data.uid}']").first().attr('data-gravity')
      html = Mustache.to_html @tpl('show'),
        alt_text: data.alt_text,
        filename: data.filename, 
        size: data.size,
        mime_type: data.mime_type,
        keywords: data.keywords,
        src: url, 
        orientation: data.orientation, 
        id: data.id,
        uid: data.uid,
        gravity: gravity,
        update_url: "#{@options.base_url}#{update_url}",
        delete_url: "#{@options.base_url}#{delete_url}",
        gravity_url: "#{@options.base_url}#{gravity_url}"
      $.facebox("<div class=\"asset-detail\">#{html}</div>")
    # Instantiate Clippy
    $('.clippy').clippy clippy_path: '/assets/ample_assets/clippy.swf'
    # Update the asset timestamp.
    @touch(data)
  
  # Create new image element from `src`, insert into `el` and fadeIn opacity.
  load_img: (el,src) ->
    img = new Image()
    $(img).load(->
      $(this).hide()
      $(el).html this
      $(this).fadeIn()
    ).attr src: src
  
  # Generates the next URL for paginated record sets.
  next_page_url: (i) ->
    @options.pages[i]['pages_loaded'] = 0 unless @options.pages[i]['pages_loaded']
    @options.pages[i]['pages_loaded'] += 1
    "#{@options.pages[i]['url']}?page=#{@options.pages[i]['pages_loaded']}"
  
  # By touching asset records, we update the timestamp value which ensures our recently
  # viewed tab contains accurate results. Called from `modal_open()`
  touch: (el) ->
    @log "touch()"
    touch_url = Mustache.to_html @options.touch_url, { id: el.id }
    $.post "#{@options.base_url}#{touch_url}"
  
  # Instantiate an amplePanels instance within page `i` if `@options.pages[i]['panels']` is true.
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
  
  # Disable all panels, preventing any loading or key-driven actions from taking place within any amplePanels instance.
  disable_panels: ->
    @log "disable_panels()"
    ref = this
    @controls(false)
    $.each @options.pages, (i,el) ->
      $(ref.options.pages[i]['panel_selector']).amplePanels('disable') if ref.options.pages[i]['panel_selector']
  
  # Enable panels instance contained with page identified by `i`. 
  # This allows key-events and previous/next actions to be executed. 
  enable_panel: (i) ->  
    @log "enable_panel(#{i})"
    if @options.pages[i]['panel_selector']
      @active_panel = @options.pages[i]['panel_selector']
      $(@options.pages[i]['panel_selector']).amplePanels('enable') 
      @controls()
  
  # Toggles display of left/right arrows which control amplePanels paging event, determined by `display`.
  controls: (display=true) ->
    @log "controls(#{display})"
    display = false if $(@active_panel).find('li').length < @options.pages_options.per_page
    switch display
      when true
        $('nav.controls').show()
      when false
        $('nav.controls').hide()
  
  # Evaluates whether URL attached to page `i` has been loaded yet. Returns `boolean`.
  already_loaded: (i) ->
    typeof @options.pages[i]['loaded'] == 'boolean' && @options.pages[i]['loaded']
  
  # Removes the asset from drop-target identified by `el`.
  remove: (el) ->
    parent = $(el).parent()
    parent.find('.droppable').empty().html('<span>Drag Asset Here</span>')
    parent.find('input').val('')
    $(el).hide()
  
  # Called upon successful DELETE request for a specific asset. Removes any instances of
  # asset identified by `id`, closes the modal window and reloads the first tab.
  delete: (id) ->
    @log "delete(#{id})"
    $("a#file-#{id}").parent().remove()
    $(document).trigger('close.facebox')
    @reload(0)
    false
  
  # Upon collapse, we disable panels.
  collapse: ->
    $("##{@options.id}-handle").css('bottom',-35).show().animate({'bottom': 0},'fast')
    @disable_panels()
  
  # Expands the asset toolbar and reenables the currently loaded tab. 
  expand: ->
    @goto(@current)
  
  # Setup all associated events.
  events: ->
    @modal_events()
    @global_events()
    @field_events()
    @drop_events()
    @drag_events()
    @reload_events()
    @resize_events()
    @key_events()
    @tab_events()
    ref = this
    # Collapse toolbar
    $("##{@options.id} a.collapse").live 'click', =>
      @toggle()
    # Reload the first tab following a successful upload. 
    $('body').bind 'ample_uploadify.complete', =>
      @reload(0)
    # Bind event to succesful deletion of an asset.
    $("a.asset-delete").live 'ajax:success', ->
      id = parseInt $(this).attr('data-id')
      ref.delete(id)
    # Bind live event to any asset-remove element.
    $("a.asset-remove").live 'click', ->
      ref.remove(this)
      false
    # Bind `toggle()` method to toolbar handle.
    $("##{@options.id}-handle").live 'click', =>
      @toggle()
      false
  
  # Bind events for global left/right arrows to currently active panel's `previous()` and `next()` methods. 
  global_events: ->
    $('a.global.next').click =>
      $(@active_panel).amplePanels('next')
    $('a.global.previous').click =>
      $(@active_panel).amplePanels('previous')
  
  # TODO: kill key events during drag?
  drag_events: ->
    @log "drag_events()"
  
  # Open modal window when clicking an asset contained with a drop-target.
  drop_events: ->
    ref = this
    $('.asset-drop .droppable a').live 'click', ->
      id = $(this).attr("href")
      $.get $(this).attr("href"), (response) ->
        ref.modal_open(response)
      , 'json'
      false
  
  # Toggle the active state of key_events when user focuses / blurs on textareas or input fields.
  field_events: ->
    @log "field_events()"
    $('textarea, input').live 'blur', =>
      @keys_enabled = true
    $('textarea, input').live 'focus', =>
      @keys_enabled = false
  
  # Bind `reload()` method to assets-reload button. 
  reload_events: ->
    @log "reload_events()"
    reload = $('<a href="#" class="assets-reload"><span></span></a>')
    reload.appendTo('.asset-refresh').click (e) =>
      @reload(@current)
  
  # Builds the markup for an asset dropped into a textarea. 
  resize_events: ->
    $('.asset-resize').live 'click', =>
      constraints = $('#asset-constraints').val()
      uid = $('#asset-uid').val()
      width = $('#asset-width').val()
      height = $('#asset-height').val()
      alt = $('#asset-alt').val()
      geometry = "#{width}x#{height}#{constraints}"
      if constraints == '#' && (width == '' || height == '')
        alert 'Can\'t resize image using this geometry. Please select another option or supply a value for both width and height.'
      else 
        url = encodeURI "#{@options.base_url}#{@options.thumb_url}/#{geometry}?uid=#{uid}"
        url = url.replace('#','%23')
        textile = "!#{url}(#{alt})!"
        html = "<img src=\"#{url}\" alt=\"#{alt}\" />"
        $(@target_textarea).insertAtCaret (if $(@target_textarea).hasClass('textile') then textile else html)
        $(document).trigger('close.facebox')
  
  # Toggles params when modal window is opened or closed. 
  modal_events: ->
    @modal_active = false
    $(document).bind 'afterClose.facebox', =>
      @keys_enabled = true
      @modal_active = false
    $(document).bind 'loading.facebox', =>
      @keys_enabled = false
      @modal_active = true
  
  # Setup amplePanels instance for search results and bind search field to methods that 
  # execute request and parse response. 
  search: ->
    @log 'search()'
    search_url = "#{@options.base_url}#{@options.search_url}"
    i = ($("##{@options.id} .pages .page").length - 1)
    ref = this
    $('#asset-results ul').attr('id','assets-result-list').amplePanels(@options.pages_options)
    @options.pages[i] = { loaded: true }
    $('#asset-search').bind 'change', ->
      $("#asset-results ul").amplePanels('empty')
      ref.loading.show()
      ref.controls(false)
      ref.show(i)
      ref.activate(i)
      ref.searching = true
      $('.asset-results').show()
      $.post search_url, $(this).serialize(), (response) ->
        ref.load_results(response)
      , 'json'
  
  # Bind events to tabs. 
  tab_events: ->
    tabs = $("##{@options.id} a.tab")
    ref = this
    $.each tabs, (idx, el) ->
      $(this).addClass('on') if idx == 0
      $(el).click ->
        ref.goto(idx)
        false
  
  # Controls all user keyboard events. Binds as neccesary and 
  # prevents interaction when key functions are disabled. 
  key_events: ->
    ref = this
    previous = 37
    next = 39
    up = 38
    down = 40
    escape = 27
    
    # Why does this need to be on keyup?
    $(document).keyup (e) =>
      return unless @keys_enabled
      switch e.keyCode
        when escape
          @toggle() unless @modal_active
      e.stopPropagation();
    
    # Keydown events.
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
  
  # Returns Mustache template for template defined by `view`
  tpl: (view) ->
    @tpls()[view]
  
  # Returns object containing all Mustache templates.
  tpls: ->
    # Layout returns the HTML structure of the main asset toolbar.
    layout: '
    <div id="{{ id }}"><div class="background">
      <a href="#" class="collapse">Close</a>
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
    # Handle returns HTML for the asset toolbar toggle handle.
    handle: '<a href="#" id="{{ id }}-handle" class="handle">{{ title }}</a>'
    # Tab returns HTML for each tab instance. 
    tab: '<a href="#" data-role="{{ id }}" class="tab {{ classes }}">{{ title }}</a>'
    # Page returns generic HTML structure for each page.
    page: '
    <div id="{{ id }}" class="page">
      <ul></ul>
    </div>'
    # Show represents the HTML used within the modal window detail view for non-document assets.
    show: '
    <div class="asset-detail">
      <div class="asset-media {{ orientation }}">
        <img src="{{ src }}" />
      </div>
      <input id="file_attachment_gravity" name="file[attachment_gravity]" type="hidden" value="{{ gravity }}">
      <div id="asset-gravity-handle" style="display:none" data-role="gravity"></div>
      <script type="text/javascript">
        $(document).ready(function() {
        	new AmpleAssetsGravity({url: "{{ gravity_url }}", uid: "{{ uid }}"});
        });
      </script>
      <div id="asset-gravity-notification">Asset updated successfully.</div>
      <a href="{{ delete_url }}" class="asset-delete" data-id="{{ id }}" data-method="delete" data-confirm="Are you sure?" data-remote="true">Delete This Asset?</a>
      <h3>{{ filename }} <span class="clippy">{{ src }}</span></h3><hr />
      <ul>
        <li>Original Dimensions: <strong>{{ size }}</strong></li>
        <li>MimeType: <strong>{{ mime_type }}</strong></li>
        <li>Orientation: <strong>{{ orientation }}</strong></li>
      </ul>
      <form action="{{ update_url }}" data-remote="true" method="put">
      <div class="inputs">
        <div class="input-l">
          <label>Alt Text</label>
          <input type="text" name="file[alt_text]" id="file_alt_text" value="{{ alt_text }}" class="string" /><br>
        </div>
        <div class="input-l">
          <label>Keywords</label>
          <input type="text" name="file[keywords]" id="file_keywords" value="{{ keywords }}" class="string" />
        </div>
        <div class="input-l form-actions">
          <button name="submit" data-disable-with="Saving...">Save</button>
        </div>
      </div>
      </form>
    </div>'
    # PDF represents the HTML used within the modal window detail view for document assets.
    pdf: '
    <div class="asset-detail">
      <div id="pdf" class="asset-media"></div>
        <a href="{{ delete_url }}" class="asset-delete" data-id="{{ id }}" data-method="delete" data-confirm="Are you sure?" data-remote="true">Delete This Asset?</a>
        <h3>{{ filename }} <span class="clippy">{{ url }}</span></h3><hr />
        <ul>
          <li>MimeType: <strong>{{ mime_type }}</strong></li>
        </ul>
        <p>{{ keywords }}</p>
    </div>'
    # There's no content within this panels instance... 
    empty: '<li class="empty">Oops. There\'s nothing here. You should <a href="#">upload something</a>.</li>'
    # Your search query returned an empty result set...
    no_results: '<li class="empty">Sorry. Your search returned zero results.</li>'
    # Drop returns HTML used in the modal window resize view. This is used when dropping an asset onto a textarea.
    drop: '
    <div class="asset-selection">
      <div class="asset-media {{ orientation }}">
        <img src="{{ src }}" />
      </div>
      <div class="asset-dimensions">
        <p><label>Image Dimensions</label> ({{ dimensions }}, {{ orientation }})</p>
        <p><select id="asset-constraints" name="asset-constraints">
            <option value="">Maintain aspect ratio</option>
            <option value="!">Force resize, don\'t maintain aspect ratio</option>
            <option value=">">Resize only if image larger than this</option>
            <option value="<">Resize only if image smaller than this</option>
            <option value="^">Resize to minimum x,y, maintain aspect ratio</option>
            <option value="#">Resize, crop if necessary to maintain aspect ratio</option>
           </select></p>
        <p><input type="hidden" id="asset-dimensions-target" name="asset-dimensions-target" value="" />
           <input type="hidden" id="asset-uid" name="asset-uid" value="{{ uid }}" />
           <input type="text" id="asset-width" name="asset-width" value="480" /> <span>x</span> 
           <input type="text" id="asset-height" name="asset-height" value="" /><br />
           <input type="text" id="asset-alt" name="asset-alt" value="" placeholder="Alt text" />
           <input type="submit" id="asset-resize" name="asset-resize" class="asset-resize" value="Insert" /></p>
        
      </div>
      <hr class="space" />
    </div>'
    

# Extend draggable to elements added to the DOM after page load. 
jQuery.fn.liveDraggable = (opts) ->
  @live "mouseover", ->
    $(this).data("init", true).draggable opts  unless $(this).data("init")
    
# Insert `value` at the cursor position of the currently focused textarea or input field.
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

