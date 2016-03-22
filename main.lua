function love.load()

	local reduc = 1

	local img = love.graphics.newImage(reduc..'.png')

	mario = love.graphics.newImage('Ninja_frame.png')
	data = mario:getData()

	psystem = love.graphics.newParticleSystem(img, 1)
	psystem:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
	psystem:setLinearAcceleration(-10, -10, 10, 10) -- Randomized movement towards the bottom of the screen.
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.
	psystem:setSpeed( 15, 20 )
	-- psystem:setDirection(0)
	psystem:setSpread( 2 * 3.14 )
	psystem:setRotation(5)
	-- psystem:setRelativeRotation( true )

	canevas = love.graphics.newCanvas(500, 500)
	canevas:setFilter('nearest', 'nearest')

	dead = false



	tab = {}
	for x = 1, mario:getWidth() / reduc do
		for y = 1, mario:getHeight() / reduc do
			local r, g, b, a = data:getPixel( x * reduc - 1, y * reduc - 1 )
			if a == 255 then
				local ps = psystem:clone()

				ps:setColors(r, g, b, a, r, g, b, a)

				table.insert(tab, {
					ps = ps,
					x = x * reduc,
					y = y * reduc
				})
			end
		end
	end
end

function love.draw()


	love.graphics.setCanvas(canevas)
		love.graphics.clear()

		love.graphics.print(love.timer.getFPS(), 5, 10)

		for k,v in ipairs(tab) do
			love.graphics.draw(v.ps, v.x + 50, v.y + 50)
		end

		if not dead then
			love.graphics.draw(mario, 50, 50)
		end

	-- love.graphics.draw(mario, 0, 0)

	love.graphics.setCanvas()

	love.graphics.draw(canevas, 0, 0, 0, 1)
end

function love.update(dt)
	for k,v in ipairs(tab) do
		v.ps:update(dt)
	end
end

function love.keypressed(key)

	if key == 'space' then
		dead = true
		for k,v in ipairs(tab) do
			v.ps:emit(1)
		end
	end
	if key == "e" then
		dead = false
	end
end
