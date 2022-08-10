--[[
  BoinBoin: mathematically accurate bouncing ball
]]

-- debug stuff
local debugMode = false
local fpBallColors = {
  ['normal']      = {0,   0.6, 0}, -- green
  ['off-limits']  = {1,   0,   0}, -- red
  ['corrected']   = {1,   1,   0}, -- yellow
  ['has-bounced'] = {0,   0.7, 1}, -- blue
}
local debugInfo = {
  fpBalls = {},
  fpLines = {}
}

-- normal stuff
local bb = {}
local defaultBallSpeed = 300 -- pixels/s

local addFpBall = function(x, y, r, t) -- x, y, radius, type
  if not debugMode then return end

  local data = {
    x = x,
    y = y,
    r = r,
    t = t,
    color = fpBallColors[t]
  }
  table.insert(debugInfo.fpBalls, data)
end

local function getIntersection(p1, p2, p3, p4)
  local deltaX = p1.x - p2.x
  local deltaY = p3.y - p4.y
  local deltaX2 = p1.y - p2.y
  local deltaY2 = p3.x - p4.x
  local d = deltaX * deltaY - deltaX2 * deltaY2 -- down part

  if d == 0 then
    error('Number of intersection points is zero or infinity.')
  end

  -- upper part of the formula
  local u1 = p1.x * p2.y - p1.y * p2.x
  local u4 = p3.x * p4.y - p3.y * p4.x

  -- intersection point
  local x = (u1 * deltaY2 - deltaX * u4) / d
  local y = (u1 * deltaY - deltaX2 * u4) / d
  
  return x, y
end

local function calculateReboundProjection(direction, newX, newY, ball)
  if direction == 'left' or direction == 'right' then
    ball.x = ball.x + (newX - ball.x) * 2
    ball.hv = -ball.hv
  elseif direction == 'top' or direction == 'bottom' then
    ball.y = ball.y + (newY - ball.y) * 2
    ball.vv = -ball.vv
  end

  return ball.x, ball.y
end

local function getPairOfLines(ball, offsetX1, offsetY1, offsetX2, offsetY2)
  return { x = ball.box.x + offsetX1, y = ball.box.y + offsetY1 },
         { x = ball.box.x + offsetX2, y = ball.box.y + offsetY2 },
         { x = ball.x,                y = ball.y                },
         { x = ball.previousX,        y = ball.previousY        }
end

-- local function getDistanceBetweenPoints(p1, p2)
--   local dx = p2.x - p1.x
--   local dy = p2.y - p1.y

--   return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
-- end

-- more debug

bb.debug = function ()
  debugMode = true
end

bb.drawDebug = function ()
  for i = 1, #debugInfo.fpBalls do
    local ball = debugInfo.fpBalls[i]
    love.graphics.setColor(ball.color)
    love.graphics.circle('line', ball.x, ball.y, ball.r)
  end
end
-- end of debug

bb.newBox = function (data)
  data = data or {}
  return {
    x = data.x or 0,
    y = data.y or 0,
    w = data.w or love.graphics.getWidth(),
    h = data.h or love.graphics.getHeight(),
  }
end

bb.newBall = function (data)
  data = data or {}
  if not data.box then
    error('A ball should be associated to a box.')
  end

  local ball = {
    x = (box.x + data.x) or (box.x + box.w / 2),
    y = (box.y + data.y) or (box.y + box.h / 2),
    r = data.r or (((box.w + box.h) / 2) / 30), -- radius
    box = data.box,
    hv = data.hv or defaultBallSpeed, -- horizontal velocity
    vv = data.vv or -defaultBallSpeed, -- vertical velocity
  }

  function ball:isBeyondLeft()
    return (self.x - self.r) < self.box.x
  end

  function ball:isBeyondRight()
    return (self.x + self.r) > (self.box.x + self.box.w)
  end

  function ball:isBeyondTop()
    return (self.y - self.r) < self.box.y
  end

  function ball:isBeyondBottom()
    return (self.y + self.r) > (self.box.y + self.box.h)
  end

  function ball:isBeyondBox()
    return self:isBeyondLeft() or
           self:isBeyondRight() or
           self:isBeyondTop() or
           self:isBeyondBottom()
  end

  return ball
end

bb.updateBall = function (ball, deltaTime, cb)
  -- if ball.status == 'halted' then
  --   return
  -- end

  ball.previousX = ball.x
  ball.previousY = ball.y

  ball.x = ball.x + ball.hv * deltaTime
  ball.y = ball.y + ball.vv * deltaTime
  cb = cb or function (evt) end -- bounce event

  -- gravity (WIP)
  -- ball.y = ball.y + 200 * deltaTime

  if ball:isBeyondBox() then
    cb({ type = 'rebound' })
    addFpBall(ball.x, ball.y, ball.r, 'off-limits')
  else
    --addFpBall(ball.x, ball.y, ball.r, 'normal')
  end

  local bx = ball.box
  if ball:isBeyondLeft() then
    local newX, newY = getIntersection(getPairOfLines(ball, ball.r, 0, ball.r, bx.h))
    addFpBall(newX, newY, ball.r, 'corrected')
    local cx, cy = calculateReboundProjection('left', newX, newY, ball)
    addFpBall(cx, cy, ball.r, 'has-bounced')
  end

  if ball:isBeyondRight() then
    local newX, newY = getIntersection(getPairOfLines(ball, bx.w - ball.r, 0, bx.w - ball.r, bx.h))
    addFpBall(newX, newY, ball.r, 'corrected')
    local cx, cy = calculateReboundProjection('right', newX, newY, ball)
    addFpBall(cx, cy, ball.r, 'has-bounced')
  end

  if ball:isBeyondTop() then
    local newX, newY = getIntersection(getPairOfLines(ball, 0, ball.r, bx.w, ball.r))
    addFpBall(newX, newY, ball.r, 'corrected')
    local cx, cy = calculateReboundProjection('top', newX, newY, ball)
    addFpBall(cx, cy, ball.r, 'has-bounced')
  end

  if ball:isBeyondBottom() then
    local newX, newY = getIntersection(getPairOfLines(ball, 0, bx.h - ball.r, bx.w, bx.h - ball.r))
    addFpBall(newX, newY, ball.r, 'corrected')
    local cx, cy = calculateReboundProjection('bottom', newX, newY, ball)
    addFpBall(cx, cy, ball.r, 'has-bounced')
  end
end

return bb
