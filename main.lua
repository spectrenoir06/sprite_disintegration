local vector = require "vector"


function love.load()

	reduc = 1 -- taile des pixel (1-5)
	zoom  = 1  -- (zoom 1 - 999)

	img = {}

	for i = 1, 5 do
		img[i] = love.graphics.newImage(i..'.png')
	end

	offX = 0
	offY = 0


	psystem = love.graphics.newParticleSystem(img[reduc], 500)
	psystem:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
	psystem:setLinearAcceleration(-10, -10, 10, 10) -- Randomized movement towards the bottom of the screen.
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.
	psystem:setSpeed(400, 500)
	psystem:setDirection(0)
	psystem:setSpread(0.3)
	psystem:setRotation(5)
	psystem:setLinearDamping(1, 1.5)
	-- psystem:setRelativeRotation( true )

	canevas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	canevas:setFilter('nearest', 'nearest')

	dead = false

	timer = 0

	all = {
		{
			img = love.graphics.newImage('avion.png'),
			particules = {},
			x = 150,
			y = 10,
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
			img = love.graphics.newImage('ninja.png'),
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

end

function spawn(explox, exploy)
	local explo = vector(explox, exploy)
	for _, obj in ipairs(all) do
		obj.particules = {}
		obj.timer = 0
		local data = obj.img:getData()
		for x = 1, obj.img:getWidth() / reduc do
			for y = 1, obj.img:getHeight() / reduc do
				local r, g, b, a = data:getPixel(x * reduc - 1, y * reduc - 1)
				if a == 255 then
					if obj.particules[string.format("#%x%x%x",r,g,b)] == nil then
						local ps = psystem:clone()
						local v = vector(x + obj.x, y + obj.y)
						ps:setDirection(v:angleTo(explo))
						ps:setColors(r, g, b, a, r, g, b, a)
						obj.particules[string.format("#%x%x%x",r,g,b)] = ps
						ps:setPosition(obj.x + x * reduc, obj.y + y * reduc)
						ps:emit(1)
					else
						local ps = obj.particules[string.format("#%x%x%x",r,g,b)]
						ps:setPosition(obj.x + x * reduc, obj.y + y * reduc)
						ps:emit(1)
					end
				end
			end
		end
	end
end

function love.draw()
	love.graphics.setCanvas(canevas)
		love.graphics.clear()

		love.graphics.push()
			love.graphics.translate(offX, offY)

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

	love.graphics.draw(canevas, 0, 0, 0, zoom)

	love.graphics.print("FPS: "..love.timer.getFPS(), 5, 10)
	love.graphics.print("Particules systemes: "..nb_ps, 5, 25)
	love.graphics.print("Zoom: "..zoom, 5, 40)
	love.graphics.print("Particule size: "..reduc, 5, 55)
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
end

function love.keypressed(key)

	if key == 'space' then
		dead = true
		spawn(0, 0)
	end
	if key == "f2" then
		zoom = zoom + 1
	end
	if key == "f1" then
		zoom = (zoom > 1) and (zoom - 1) or 1
	end
	if key == "f4" then
		reduc = (reduc > 1) and (reduc - 1) or 1
		psystem:setTexture( img[reduc] )
	end
	if key == "f3" then
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
	spawn(x, y)
end
