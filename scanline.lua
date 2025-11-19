---Scanline
--
--
--
-- ................................................................
--
--
--
-- by xmacex

local WIDTH   = 128
local HEIGHT  = 64
local scenes  = {}
local k3shift = 0

engine.name = 'Scanline'

function init()
    init_scenes()
    init_params()
    init_image()
    init_crow()
    norns.crow.add = init_crow
    print("init scanline")

    engine.play(1)
    redraw()
end

function init_scenes()
  for i,k in ipairs(util.scandir(paths.this.lib)) do
    if string.sub(k, -4) == ".png" then
      table.insert(scenes, string.sub(k, 1, -5))
    end
  end
end

function init_params()
    params:add_control('amp', "amp", controlspec.AMP)
    params:set_action('amp', function(v)
        engine.amp(v)
    end)
    params:set('amp', 0.2)

    params:add_number('line', "line", 1, HEIGHT, HEIGHT/2)
    params:set_action('line', function(v)
        line = screen.peek(0, math.floor(v)-1, WIDTH, 1)
        line_n = {}
        for i=1, WIDTH do
            table.insert(line_n, string.byte(line, i)/16)
        end
        engine.scanline(table.unpack(line_n))
        redraw()
    end)

    params:add_taper('rate', "rate", 0.01, HEIGHT, 1)
    params:set_action('rate', function(v)
        engine.rate(v)
    end)
    
    params:add_taper('lag', "lag", 0, 10, 1)
    params:set_action('lag', function(v)
        engine.lag(v)
    end)

    params:add_option('scene', "scene", scenes)
    params:set_action('scene', function(v)
        local path = paths.this.lib..scenes[v]..".png"
        image = screen.load_png(path)
        redraw()
    end)
end

function init_image()
    print(paths.this.lib..scenes[1]..".png")
    image = screen.load_png(paths.this.lib..scenes[1]..".png")
end

function init_crow()
    crow.input[1].mode('stream', 0.05)
    crow.input[1].stream = function(v)
        local val = math.floor(util.linlin(-5, 10, 0, HEIGHT, v))
        if val ~= params:get('line') then
            params:set('line', val)
        end
    end

    crow.input[2].mode('stream', 0.05)
    crow.input[2].stream = function(v)
        local val = util.linlin(-5, 10, 0.01, 2, v)
        if math.abs(val - params:get('rate')) > 0.05 then
            params:set('rate', val)
        end
    end
end

function redraw()
    screen.clear()
    draw_image()
    draw_scanline()
    screen.update()
end

function draw_image()
    screen.display_image(image, 0, 0)
end

function draw_scanline()
    screen.blend_mode('xor')
    screen.aa(0)
    screen.level(1)
    screen.line_width(1)
    screen.move(1, params:get('line'))
    screen.line(WIDTH, params:get('line'))
    screen.stroke()
end

function key(n, z)
  if n == 3 then
    shift = z
  end
end

function enc(n, d)
    if n == 1 then
        params:delta('scene', d)
    elseif n == 2 then
        params:delta('line', d)
    elseif n == 3 then
      if k3shift == 1 then
        params:delta('rate', d/20)
      else
        params:delta('rate', d)
      end
    end
end

-- Local Variables:
-- flycheck-luacheck-standards: ("lua51" "norns")
-- End:
