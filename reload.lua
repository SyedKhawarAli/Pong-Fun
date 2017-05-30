local sceneName = ...

local composer = require('composer')
local color = require "libs.convertcolor"
local relayout = require('libs.relayout')
local databox = require('libs.databox') -- Persistant storage, track level completion and settings


local scene = composer.newScene(sceneName)
local chapterNumber
-------------------------------------
function scene:create()
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

    local group = self.view

    local background = display.newRect(group, _CX, _CY, _W, _H)
    background:setFillColor(color.hex('34495e'))
    relayout.add(background)

    local label = display.newText({
        parent = group,
        text = '',
        x = _CX,
        y = _H / 3 * 2,
        font = native.systemFontBold,
        fontSize = 55
    })
    --label.anchorX, label.anchorY = 1, 1
    relayout.add(label)
end

function scene:show(event)
    if event.phase == 'will' then
        -- Preload the scene
        composer.loadScene('game')
    elseif event.phase == 'did' then
        -- Show it after a moment
        timer.performWithDelay(100, function()
            composer.gotoScene('game', { effect = "fade" })
        end)
    end
end

------------------------------------------

-- Listener setup
scene:addEventListener('create')
scene:addEventListener('show')

return scene
