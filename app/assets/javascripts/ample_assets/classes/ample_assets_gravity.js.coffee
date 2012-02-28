# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleAssetsGravity extends CoffeeCup
  
  default_options: 
    debug: true
    uid: false
    url: "/ample_assets/files/{{ id }}/gravity"
    min_width: 100
    min_height: 100
  
  init: ->
    @log "init()"
    @handle = $("#asset-gravity-handle")
    @image = $(".asset-media img")
    @test()
  
  test: ->
    if @image.width() > 0
      @html() if @image.height() > @options.min_width && @image.height() > @options.min_height
    else
      @log "@image not loaded"
      setTimeout (=> @test()), 500
  
  html: ->
    @log "html()"
    # Don't show this for tiny images
    return false unless @image.width() > 100 && @image.width() > 100
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
      stop: (event, ui) =>
        gravity_pos = [ Math.floor(ui.position.left / @gravity_grid.left), Math.floor(ui.position.top / @gravity_grid.top) ]
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
  