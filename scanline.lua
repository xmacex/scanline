---Scanline
--
--
-- ............
--
-- watch out for bad noise
--   learning norns SC

local WIDTH  = 128
local HEIGHT = 64
local scenes = {'path', 'istanbul'}

engine.name = 'Scanline'

-- TODO erm is screen.peek(32, 1, 128, 1) working?

function init()
    init_params()
    init_image()
    init_crow()
    crow.add = init_crow
    print("init scanline")

    -- engine.play(20)
    engine.play(1)
    redraw()
end

function init_params()
    params:add_taper('amp', "amp", 0.01, 2, 1)
    params:set_action('amp', function(v)
        engine.amp(v)
    end)

    params:add_number('line', "line", 1, HEIGHT, HEIGHT/2)
    params:set_action('line', function(v)
        -- TODO I feel there is off-by-one somewhere here, does the screen start from 0?
        line = screen.peek(0, math.floor(v)-1, WIDTH, 1)
        line_n = {}
        for i=1, WIDTH do
            table.insert(line_n, string.byte(line, i)/16)
        end
        engine.scanline(table.unpack(line_n))
        engine.play(params:get('rate'))
        redraw()
        end)

    params:add_taper('rate', "rate", 0.01, 2, 1)
    params:set_action('rate', function(v)
        engine.rate(rate)
        engine.play(v)
    end)
    params:add_option('scene', "scene", scenes)
    params:set_action('scene', function(v)
        local path = paths.this.lib..scenes[v]..".png"
        image = screen.load_png(path)
    end)
end

function init_image()
    -- image = screen.load_png(paths.this.lib.."istanbul.png")
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
    -- draw_circles()
    draw_scanline()
    screen.update()
end

function draw_circles()
    screen.aa(1)
    screen.circle(HEIGHT/2, HEIGHT/2, HEIGHT/3)
    screen.level(3)
    screen.line_width(4)
    screen.stroke()

    screen.circle(20, HEIGHT/4, 5)
    screen.level(8)
    screen.line_width(3)
    screen.stroke()

    screen.circle(100, 55, 10)
    screen.level(16)
    screen.line_width(7)
    screen.stroke()
end

function draw_image()
    screen.display_image(image, 0, 0)
end

function draw_scanline()
    screen.blend_mode('xor')
    screen.level(1)
    screen.aa(0)
    screen.line_width(1)
    screen.move(1, params:get('line'))
    screen.line(WIDTH, params:get('line'))
    screen.stroke()
end

function enc(n, d)
    if n == 1 then
        params:delta('amp', d)
    elseif n == 2 then
        params:delta('line', d)
    elseif n == 3 then
        params:delta('rate', d)
    end
end

-- Local Variables:
-- flycheck-luacheck-standards: ("lua51" "norns")









-- End:
