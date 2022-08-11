local bb = require 'boinboin'

function love.load()
  font = love.graphics.newFont('fonts/ProggyCleanCE.ttf', 16)
  font:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle('rough')
  ballImg = love.graphics.newImage('img/ball.png')

  bb.debug({
    lifespan = 3
  })
  box = bb.newBox({
    x = 230,
    y = 100,
    w = 400 ,
    h = 300
  })
  ball = bb.newBall({
    x = 20,
    y = 40,
    r = 16,
    box = box,
    hv = 3600,
    vv = 3500
  })

  ballStatus = 'ok'
  numberOfBounces = 0
end

function love.update(dt)
  if love.keyboard.isDown('space') then
    bb.updateBall(ball, dt, function (evt)
      if evt.type == 'rebound' then
        numberOfBounces = numberOfBounces + 1
      elseif evt.type == 'stray' then
        ballStatus = 'stray'
      end
    end)
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    ballImg,
    math.floor(ball.x),
    math.floor(ball.y), 0, 0.9, 0.9,
    math.floor(ballImg:getWidth() / 2),
    math.floor(ballImg:getHeight() / 2)
  )
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', box.x, box.y, box.w, box.h)
  bb.drawDebug()

  local debugText = 'FPS: ' .. love.timer.getFPS() ..
    '\nHorizonal velocity: ' .. (ball.hv > 0 and ' ' or '') .. ball.hv ..
    '\nVertical velovity: ' .. (ball.vv > 0 and ' ' or '') .. ball.vv ..
    '\nBall status: ' .. ballStatus ..
    '\nNumber of bounces: ' .. numberOfBounces ..
    '\nDebug balls: ' .. #bb.debugInfo.fpBalls ..
    -- '\nDebug lines: ' .. #bb.debugInfo.fpLines ..
    '\nPress space to move' ..
    '\nN = next iteration'
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(debugText, 10, 10)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(debugText, 11, 9)
end

function love.keypressed(k)
  if k == 'escape' then
    love.event.quit();
  elseif k == 'left' then
    ball.hv = ball.hv * 0.75
  elseif k == 'right' then
    ball.hv = ball.hv * 1.5
  elseif k == 'up' then
    ball.vv = ball.vv * 1.5
  elseif k == 'down' then
    ball.vv = ball.vv * 0.75
  end

  if k == 'n' then
    bb.updateBall(ball, 0.03, function (evt)
      if evt.type == 'rebound' then
        numberOfBounces = numberOfBounces + 1
      elseif evt.type == 'stray' then
        ballStatus = 'stray'
      end
    end)
  end
end
