local bb = require 'boinboin'

-- debug
local function sleep(n)
  os.execute('sleep ' .. tonumber(n))
end

function love.load()
  bb.debug()
  box = bb.newBox({
    x = 200,
    y = 100,
    -- w = love.graphics.getWidth() - 200,
    -- h = love.graphics.getHeight() - 200,
    w = 400,
    h = 400
  })
  ball = bb.newBall({
    r = 15,
    x = 50,
    y = 20,
    box = box,
    hv = 2600,
    vv = 2600
  })

  ballStatus = 'ok'
  numberOfBounces = 0
end

function love.update(dt)
  bb.updateBall(ball, dt, function (evt)
    if evt.type == 'rebound' then
      numberOfBounces = numberOfBounces + 1
    elseif evt.type == 'stray' then
      ballStatus = 'stray'
    end
  end)
end

function love.draw()
  bb.drawDebug()
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('line', ball.x, ball.y, ball.r - 2)

  local debugText = 'FPS: ' .. love.timer.getFPS() ..
    '\nLeft and Right to change horizonal velocity: ' .. ball.hv ..
    '\nUp and down to change vertical velovity: ' .. ball.vv ..
    '\nBall status: ' .. ballStatus ..
    '\nNumber of bounces: ' .. numberOfBounces

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(debugText, 10, 10)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(debugText, 11, 9)

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', box.x, box.y, box.w, box.h)
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
