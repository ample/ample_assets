# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleAssetsGravity extends CoffeeCup
  
  default_options: 
    debug: false
    uid: false
    url: "/ample_assets/files/{{ id }}/gravity"
    min_width: 100
    min_height: 100
    max_width: 480
    max_height: 300  
  
  init: ->
    @log "init()"
    @handle = $("#asset-gravity-handle")
    @image = $(".asset-media img")
    @test()
  
  test: ->
    if @image.width() > 0
      @html()
    else
      @log "@image not loaded"
      setTimeout (=> @test()), 500
  
  html: ->
    @log "html()"
    # Don't show this for tiny images
    return false unless @image.height() > @options.min_width && @image.height() > @options.min_height
    @gravity = $("#file_attachment_gravity").val() || "c"
    @gravity_grid =
      top: @image.height() / 3
      left: @image.width() / 3
    @image_pos = @image.position()
    @image_center =
      top:  (@image_pos.top  + (@image.height() / 2) - (@handle.height() / 2))
      left: (@image_pos.left + (@image.width()  / 2) - (@handle.width()  / 2))
    @handle.css
      position: "absolute"
      left: (@image_center.left - @gravity_grid.left) + (@gravity_grid.left * @gravities()[@gravity][0])
      top:  (@image_center.top  - @gravity_grid.top)  + (@gravity_grid.top  * @gravities()[@gravity][1])
    @handle.draggable
      containment: @image
      grid: [@gravity_grid.left, @gravity_grid.top]
      scroll: false,
      start: (event, ui) =>
        $('div.ui-droppable, textarea.ui-droppable').addClass('asset-inactive-target')
      stop: (event, ui) =>
        $('div.ui-droppable, textarea.ui-droppable').removeClass('asset-inactive-target')
        
        left = ui.position.left
        top = ui.position.top
        
        # Account for images smaller than max width and/or height. 
        left = Math.abs(((@options.max_width - @image.width()) / 2) - left) if @image.width() < @options.max_width
        top = Math.abs(((@options.max_height - @image.height()) / 2) - top) if @image.height() < @options.max_height
        
        gravity_pos = [ Math.floor(left / @gravity_grid.left), Math.floor(top / @gravity_grid.top) ]
        
        for key, value of @gravities()
          if value[0] is gravity_pos[0] and value[1] is gravity_pos[1]
            gravity = key
            break
        $("#file_attachment_gravity").val(gravity);
        @submit(gravity)
        @log gravity
    @handle.fadeIn()
  
  submit: (gravity) ->
    @log "submit(#{gravity})"
    $.post @options.url, { gravity: gravity }, (e) =>
      $("a[data-uid='#{@options.uid}']").attr('data-gravity',gravity)
      $('#asset-gravity-notification').show().delay(2500).fadeOut()
  
  gravities: ->
    nw: [ 0, 0 ]
    n:  [ 1, 0 ]
    ne: [ 2, 0 ]
    w:  [ 0, 1 ]
    c:  [ 1, 1 ]
    e:  [ 2, 1 ]
    sw: [ 0, 2 ]
    s:  [ 1, 2 ]
    se: [ 2, 2 ]
  