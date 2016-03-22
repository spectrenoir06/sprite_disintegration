local vector = require "vector"


function love.load()

	reduc = 1

	local img = love.graphics.newImage(reduc..'.png')

	mario = love.graphics.newImage('ninja.png')

	psystem = love.graphics.newParticleSystem(img, 1)
	psystem:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
	psystem:setLinearAcceleration(-10, -10, 10, 10) -- Randomized movement towards the bottom of the screen.
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.
	psystem:setSpeed(400, 500)
	psystem:setDirection(0)
	psystem:setSpread(0.3)
	-- psystem:setRotation(5)
	psystem:setLinearDamping( 1, 1.5 )
	-- psystem:setRelativeRotation( true )

	canevas = love.graphics.newCanvas(1280, 720)
	canevas:setFilter('nearest', 'nearest')

	dead = false

	timer = 0

	all = {
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 10,
			y = 10
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 300,
			y = 200
		},
		{
			img = love.graphics.newImage('ninja.png'),
			particules = {},
			x = 50,
			y = 150
		},
		{
			img = love.graphics.newImage('mario.png'),
			particules = {},
			x = 300,
			y = 10
		}
	}

	nb_ps = 0

end

function spawn(explox, exploy)
	local explo = vector(explox, exploy)
	for _, obj in ipairs(all) do
		obj.particules = {}
		for x = 1, obj.img:getWidth() / reduc do
			for y = 1, obj.img:getHeight() / reduc do
				local r, g, b, a = obj.img:getData():getPixel(x * reduc - 1, y * reduc - 1)
				if a == 255 then
					local ps = psystem:clone()
					local v = vector(x + obj.x, y + obj.y)
					ps:setDirection(v:angleTo(explo))
					ps:setColors(r, g, b, a, r, g, b, a)
					table.insert(obj.particules, {
						ps = ps,
						x = x * reduc,
						y = y * reduc
					})
					ps:emit(1)
				end
			end
		end
	end
end

function love.draw()
	love.graphics.setCanvas(canevas)
		love.graphics.clear()

		love.graphics.print(love.timer.getFPS().." : "..nb_ps, 5, 10)

		if not dead then
			for _, obj in ipairs(all) do
				love.graphics.draw(obj.img, obj.x, obj.y)
			end
		end

		for _, obj in ipairs(all) do
			for _, ps in ipairs(obj.particules) do
				love.graphics.draw(ps.ps, obj.x + ps.x, obj.y + ps.y)
			end
		end

	love.graphics.setCanvas()
	love.graphics.draw(canevas, 0, 0, 0, 1)
end

function love.update(dt)
	nb_ps = 0
	for _, obj in ipairs(all) do
		for _, ps in ipairs(obj.particules) do
			ps.ps:update(dt)
			nb_ps = nb_ps + 1
		end
	end
	timer = timer + dt * 50
end

function love.keypressed(key)

	if key == 'space' then
		dead = true
		spawn(0, 0)
	end
	if key == "e" then
		dead = false
	end
end


function love.mousepressed(x, y, button)
	dead = true
	spawn(x, y)
end
