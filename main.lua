local vector = require "vector"

local time = 0

function love.load()

	reduc = 1 -- taile des pixel (1-5)
	zoom  = 1  -- (zoom 1 - 999)
	reduc_color =  120 --( 1 - 256)
	max_particule_by_color = 2000

	img = {}

	for i = 1, 5 do
		img[i] = love.graphics.newImage(i..'.png')
	end

	offX = 0
	offY = 0

	bg = love.graphics.newImage('bg.png')

	psystem = love.graphics.newParticleSystem(img[reduc], max_particule_by_color)
	psystem:setParticleLifetime(1, 2)                       -- Particles live at least 2s and at most 5s.
	psystem:setLinearAcceleration(0, -0, 0, -0)             -- Randomized movement towards the bottom of the screen.
	psystem:setSpeed(400, 500)
	psystem:setSpread(0.1)
	psystem:setRotation(5)
	psystem:setLinearDamping(1, 1.5)

	canevas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	canevas:setFilter('nearest', 'nearest')

	dead = false

	timer = 0

	all = {
		{
			img = love.graphics.newImage('boo.png'),
			particules = {},
			x = 300,
			y = 300,
			timer = 0
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 300,
			y = 200,
			timer = 0
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 150,
			y = 150,
			timer = 0
		},
		{
			img = love.graphics.newImage('mario.png'),
			particules = {},
			x = 400,
			y = 50,
			timer = 0
		},
		{
			img = love.graphics.newImage('avion.png'),
			particules = {},
			x = 500	,
			y = 10,
			timer = 0
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 550,
			y = 200,
			timer = 0
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 450,
			y = 230,
			timer = 0
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 200,
			y = 100,
			timer = 0
		}
	}

	nb_ps = 0

	shader = love.graphics.newShader("wave.frag")

	shader:send('iResolution', { love.graphics.getWidth(), love.graphics.getHeight(), 1 })

end

function spawn(explox, exploy)
	local demiPi = math.pi / 2
	local atan2 = math.atan2
	local floor = math.floor

	for _, obj in ipairs(all) do
		local particules = {}
		obj.timer = 0
		local data = obj.img:getData()
		local ox, oy = obj.x, obj.y
		for x = 1, obj.img:getWidth() / reduc do
			for y = 1, obj.img:getHeight() / reduc do
				local r, g, b, a = data:getPixel(x * reduc - 1, y * reduc - 1)
				if a == 255 then
					local str = string.format("%x%x%x",
						floor(r/reduc_color),
						floor(g/reduc_color),
						floor(b/reduc_color)
					)
					local ps
					if particules[str] == nil then
						ps = psystem:clone()
						ps:setColors(r, g, b, a)
						particules[str] = ps
					else
						ps = particules[str]
					end
					local dx = explox - (ox + x)
					local dy = exploy - (oy + y)
					local rot = atan2(-dx, dy) - demiPi
					ps:setDirection(rot)
					ps:setPosition(ox + x * reduc, oy + y * reduc)
					ps:emit(1)
				end
			end
		end
		obj.particules = particules
	end
end

function love.draw()
	love.graphics.setCanvas(canevas)
		love.graphics.clear()

		love.graphics.push()
			love.graphics.translate(offX, offY)

			-- love.graphics.draw(bg, 0, 0)

			if not dead then
				for _, obj in ipairs(all) do
					love.graphics.draw(obj.img, obj.x, obj.y)
				end
			end

			for _, obj in ipairs(all) do
				for _, ps in pairs(obj.particules) do
					love.graphics.draw(ps, 0, 0)
				end
			end
		love.graphics.pop()
	love.graphics.setCanvas()

	if dead then
		love.graphics.setShader(shader)
	end
	love.graphics.draw(canevas, 0, 0, 0, zoom)

	love.graphics.setShader()

	love.graphics.print("FPS: "..love.timer.getFPS(), 5, 10)
	love.graphics.print("Particules systemes: "..nb_ps, 5, 25)
	love.graphics.print("Zoom: "..zoom, 5, 40)
	love.graphics.print("Particule size: "..reduc, 5, 55)
	love.graphics.print("reduc color:"..reduc_color, 5, 70)

	love.graphics.print("[space] or Click = destroy", 5, 170)
	love.graphics.print("[f1-f2] = zoom", 5, 185)
	love.graphics.print("[f3-f4] = zoom", 5, 200)
	love.graphics.print("[mouse wheel] = color", 5, 215)

end

function love.update(dt)
	nb_ps = 0
	for _, obj in ipairs(all) do
		for _, ps in pairs(obj.particules) do
			ps:update(dt)
			nb_ps = nb_ps + 1
		end
		obj.timer = obj.timer + dt
		if obj.timer > 2 then
			dead = false
			obj.particules = {}
		end
	end
	timer = timer + dt
	time = dt + time;

	if dead then
		-- shader:send('iResolution', { love.graphics.getWidth(), love.graphics.getHeight(), 1 })
		shader:send('iGlobalTime', time)
	end
end

function love.keypressed(key)

	if key == 'space' then
		dead = true
		spawn(720, 480)
	end
	if key == "f1" then
		zoom = zoom + 1
	end
	if key == "f2" then
		zoom = (zoom > 1) and (zoom - 1) or 1
	end
	if key == "f3" then
		reduc = (reduc > 1) and (reduc - 1) or 1
		psystem:setTexture( img[reduc] )
	end
	if key == "f4" then
		reduc = (reduc < 5) and (reduc + 1) or 5
		psystem:setTexture( img[reduc] )
	end

	if key == "up" then
		offY = offY + 10
	end
	if key == "down" then
		offY = offY - 10
	end

	if key == "left" then
		offX = offX + 10
	end
	if key == "right" then
		offX = offX - 10
	end
end


function love.mousepressed(x, y, button)
	dead = true
	time = 0
	shader:send('iMouse', { love.mouse.getX() / zoom, love.mouse.getY() / zoom, 0, 0 })
	spawn(x / zoom, y / zoom)
end


function love.wheelmoved( x, y )
	-- print(x,y)
	reduc_color = reduc_color + y
	if reduc_color < 1 then reduc_color = 1 end
	if reduc_color > 256 then reduc_color = 256 end
end
