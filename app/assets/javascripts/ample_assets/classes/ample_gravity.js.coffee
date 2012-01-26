# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleGravity

  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()

  set_options: (opts) ->
    @options = {
      debug: true
    }
    for k of opts
      @options[k] = opts[k]

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
        @log gravity
    @handle.fadeIn()
    
  log: (msg) ->
    console.log "ample_gravity.log: #{msg}" if @options.debug

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