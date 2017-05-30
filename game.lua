---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require("composer")
local widget = require('widget')


local relayout = require "libs.relayout"
local color = require "libs.convertcolor"
local sounds = require('libs.sounds')
local physics = require "physics"
local databox = require('libs.databox')

-- Load scene with same root filename as this file
local scene = composer.newScene(sceneName)

---------------------------------------------------------------------------------

local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
local bar, bgRect --, ball_2
local barSpeed = 0
function scene:create(event)
    local sceneGroup = self.view

    bgRect = display.newRect(_CX, _CY, _W, _H)
    bgRect:setFillColor(color.hex('34495e'))
    --bgRect:setFillColor(color.rgb(0, 188, 212))
    sceneGroup:insert(bgRect)


    local visualButtons = {}
    local musicButtons = {}

    local function updateDataboxAndVisibility()
        databox.isMusicOn = sounds.isMusicOn
        musicButtons.on.isVisible = false
        musicButtons.off.isVisible = false
        if databox.isMusicOn then
            musicButtons.on.isVisible = true
        else
            musicButtons.off.isVisible = true
        end
    end

    musicButtons.on = widget.newButton({
        defaultFile = 'sound.png',
        overFile = 'sound.png',
        x = _W / 10,
        y = _H / 16,
        onRelease = function()
            sounds.play('tap')
            sounds.isMusicOn = false
            updateDataboxAndVisibility()
            sounds.stop()
        end
    })
    musicButtons.on.anchorX, musicButtons.on.anchorY = 0, 0
    musicButtons.on.alpha = 0.5
    sceneGroup:insert(musicButtons.on)
    table.insert(visualButtons, musicButtons.on)

    musicButtons.off = widget.newButton({
        defaultFile = 'mute.png',
        overFile = 'mute.png',
        x = musicButtons.on.x,
        y = musicButtons.on.y,
        onRelease = function()
            sounds.play('tap')
            sounds.isMusicOn = true
            updateDataboxAndVisibility()
            sounds.playStream('game_music')
        end
    })
    musicButtons.off.anchorX, musicButtons.off.anchorY = 0, 0
    musicButtons.off.alpha = 0.5
    sceneGroup:insert(musicButtons.off)
    table.insert(visualButtons, musicButtons.off)

    updateDataboxAndVisibility()
    sounds.playStream('game_music')

    ------------------------------------------------- side walls --------------------------------

    local leftRect = display.newRect(0, _CY, 0, _H)
    physics.addBody(leftRect, "static")

    self.bottomRect = display.newRect(_CX, _H, _W, 0)
    self.bottomRect:setFillColor(color.rgb(500, 188, 212))
    physics.addBody(self.bottomRect, "static", { bounce = -0.5 })

    local rightRect = display.newRect(_W, _CY, 0, _H)
    physics.addBody(rightRect, "static")

    local topRect = display.newRect(_CX, 0, _W, 0)
    physics.addBody(topRect, "static")

    -------------------------------------- ball -------------------

    ball_2 = display.newCircle(_CX / 3, _H / 4 * 1, _W / 21)
    physics.addBody(ball_2, "dynamic", { radius = _W / 21, density = 0.1, bounce = 0.8 })
    ball_2:applyForce(55, 0, ball_2.x, ball_2.y)
    sceneGroup:insert(ball_2)

    bar = display.newRect(_CX, _H / 7 * 6, _W / 12 * 3, _H / 89) --_W/12*3
    bar.anchorX, bar.anchorY = 0.5, 1
    physics.addBody(bar, "kinematic", { bounce = math.random(1.1, 1.3) })
    sceneGroup:insert(bar)

    self.score = 0
    self.scoreText = display.newText("0", _CX, _H / 4 * 1 + _H / 8, native.systemFont, 89)
    self.scoreText.alpha = 0.5
    self.scoreText:setFillColor(1, 1, 1, 1)
    sceneGroup:insert(self.scoreText)

    self.colorTable = { "2c3e50", "9b59b6", "8e44ad", "1abc9c", "2ecc71", "3498db", "2980b9", "2ecc71", "27ae60", "e67e22", "d35400", "f1c40f", "f39c12", "e74c3c", "c0392b", "34495e" }
    self.colorTable2 = { "3f51b5", "673ab7", "9c27b0", "e91e63", "f44336", "4caf50", "009688", "00bcd4", "03a9f4", "03a9f4", "2196f3", "ff9800", "ffc107", "ff5722", "795548", "34495e" }
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        databox.score = 0
        physics.start()

    elseif phase == "did" then
        sounds.playStream('game_music')

        local function moveBar(event)
            if (event.phase == "began") then
                if (event.x > _CX and bar.x < _W - bar.width / 2) then
                    local distanceFronDestni = ((_W - bar.width / 2) - bar.x)

                    --bar:setLinearVelocity(distanceFronDestni, 0)
                    transition.to(bar, { time = distanceFronDestni, x = _W - bar.width / 2, transition = easing.inOutSine })
                    --bar.x = bar.x + 20
                elseif (event.x <= _CX and bar.x > 0 + bar.width / 2) then
                    local distanceFronDestni = (bar.x - bar.width / 2)
                    --bar:setLinearVelocity(-distanceFronDestni, 0)

                    transition.to(bar, { time = distanceFronDestni, x = 0 + bar.width / 2, transition = easing.inOutSine })
                end
                --[[  elseif event.phase == "moved" then
                      if (bar.x < _W - bar.width / 2 or _CX and bar.x > 0 + bar.width / 2) then
                          bar:setLinearVelocity(0, 0)
                      end]]

            elseif (event.phase == "ended") then
                --bar:setLinearVelocity(0, 0)

                transition.cancel()
            end
            return true
        end

        local index = 1
        local function addScore(event)
            sounds.play('impact')
            if (index == 16) then
                bgRect:setFillColor(color.hex(self.colorTable2[index]))
                index = 1
            else
                bgRect:setFillColor(color.hex(self.colorTable2[index]))
                index = index + 1
            end
            self.score = self.score + 1
            databox.score = databox.score + 1
            self.scoreText.text = self.score
            if (barSpeed > 0) then
                --event.other:applyForce(-barSpeed, 0, event.other.x, event.other.y)
                local vx, vy = event.target:getLinearVelocity()
                event.other:setLinearVelocity(vx + barSpeed, -vy)
                print("bar linear velocit:" .. barSpeed)
            elseif (barSpeed < 0) then
                local vx, vy = event.target:getLinearVelocity()
                event.other:setLinearVelocity(vx + barSpeed, -vy)
                --event.target:applyForce(-barSpeed, 0, event.other.x, event.other.y)
                print("bar linear velocit:" .. barSpeed)
            end
            print(" force " .. event.other:getLinearVelocity())
            --ball_2:applyForce(5000, -100, ball_2.x, ball_2.y)
            print("bar linear velocit:" .. barSpeed)
            --print("bar.x:"..bar.x.." event.x:"..event.target.x.." event.other.x: "..event.other.x)
            bar:removeEventListener("collision", addScore)
            local function addCollionsLisnerBar()
                bar:addEventListener("collision", addScore)
            end

            timer.performWithDelay(1, addCollionsLisnerBar, 1)
            if (databox.score == 100) then
                physics.pause()
                timer.pause(addBallTimer)
                self:congPopup()
            end
        end

        local function callbackListener()
            audio.setVolume(1)
        end

        local function showBallBroken(locationX)
            local function addBalls()
                local ballB = display.newCircle(math.random(locationX - 10, locationX + 10), _H - 20, _W / 144)
                physics.addBody(ballB, "dynamic", { radius = _W / 144, density = 0.1, bounce = 1 })
                sceneGroup:insert(ballB)
            end

            timer.performWithDelay(10, addBalls, 21)
        end

        local function gameEnd(event)
            showBallBroken(event.other.x)
            display.remove(event.other)
            audio.setVolume(0.5)
            sounds.play('lose', { onComplete = callbackListener })
            if (databox.score > databox.highScore) then
                databox.highScore = databox.score
            end
            bar:removeEventListener("collision", addScore)
            self.bottomRect:removeEventListener("collision", gameEnd)
            Runtime:removeEventListener("touch", moveBar)
            --physics.pause()
            timer.cancel(barSpeedTimer)
            timer.cancel(addBallTimer)
            composer.gotoScene("menu", { time = 1000, effect = "fade" })
        end

        local function addBall()
            ball_2 = display.newCircle(_CX / 3, _H / 4 * 1, _W / 21)
            physics.addBody(ball_2, "dynamic", { radius = _W / 21, density = 0.1, bounce = 1 })
            ball_2:applyForce(55, 0, ball_2.x, ball_2.y)
            sceneGroup:insert(ball_2)
        end

        local pBarX = bar.x
        local function calculateBarSpeed()
            local barX = math.abs(bar.x)
            if (barX - pBarX ~= 0) then
                barSpeed = barSpeed + barX - pBarX
                --print("speed diff: "..barSpeed)
                pBarX = barX
            else
                barSpeed = 0
            end
            --print(math.abs(barX - pBarX))
        end

        barSpeedTimer = timer.performWithDelay(1, calculateBarSpeed, -1)
        addBallTimer = timer.performWithDelay(21000, addBall, 15)
        bar:addEventListener("collision", addScore)
        self.bottomRect:addEventListener("collision", gameEnd)
        Runtime:addEventListener("touch", moveBar)
    end
end

function scene:congPopup()

    local popupGroup = display.newGroup()

    local box = display.newImageRect("congImg.png", _CX, _CY, _W / 5 * 4, _H / 7 * 3, 8)
    box.x, box.y = _CX, _CY
    box.width, box.height = _W / 5 * 4, _H / 7 * 3, 8
    --box:setFillColor(1, 1, 1)
    popupGroup:insert(box)

    local congImg = display.newImage("congImg.png", _CX, _CY)
    congImg.x, congImg.y = _W / 13 * 9, _H / 13 * 5
    congImg.alpha = 0.5
    congImg.isVisible = false
    popupGroup:insert(congImg)

    local congNote = display.newText("Congratulation! ", _CX, _H / 15 * 5, native.systemFontBold, 55)
    congNote:setFillColor(1, 1, 1)
    popupGroup:insert(congNote)

    --[[local successNote = display.newText( "challenge completed! ", _CX, _H/15*7, native.systemFont, 44 )
    successNote:setFillColor(1,0,0)
    popupGroup:insert(successNote)]]

    local shareNote = display.newText("SHARE  ", _W / 7 * 4, _H / 18 * 12, "robotoMedium.ttf", 34)
    shareNote.anchorX = 1
    shareNote:setFillColor(1, 1, 1)
    popupGroup:insert(shareNote)

    local continueNote = display.newText("CONTINUE", _W / 7 * 6, _H / 18 * 12, "robotoMedium.ttf", 34)
    continueNote.anchorX = 1
    continueNote:setFillColor(1, 1, 1)
    popupGroup:insert(continueNote)

    local function continueGame()
        display.remove(popupGroup)
        local function startPhy()
            physics.start()
        end

        timer.performWithDelay(1000, startPhy, 1)
        timer.resume(addBallTimer)
    end

    local function shareCong()
        display.remove(popupGroup)
        local function captureDeviceScreen()
            self.captured_image = display.captureScreen(true)
            self.captured_image:scale(.5, .5)
            self.captured_image.x = display.contentCenterX
            self.captured_image.y = display.contentCenterY
            local function saveWithDelay()

                media.save(self.captured_image, system.DocumentsDirectory)
                --display.save( self.captured_image, { filename="screentShot.png", baseDir=system.DocumentsDirectory } )
                local function retrivateandShare()
                    self:onShareButtonReleased()
                    display.remove(self.captured_image)
                end

                timer.performWithDelay(100, retrivateandShare)
            end

            timer.performWithDelay(100, saveWithDelay)
            display.remove(self.captured_image)
        end

        timer.performWithDelay(500, captureDeviceScreen, 1)
    end

    shareNote:addEventListener("tap", shareCong)
    continueNote:addEventListener("tap", continueGame)
end

function scene:onShareButtonReleased(event)
    local serviceName = "share"
    local isAvailable = native.canShowPopup("social", serviceName)
    sounds.play('tap')
    -- If it is possible to show the popup
    if isAvailable then
        local listener = {}
        function listener:popup(event)
            print("name(" .. event.name .. ") type(" .. event.type .. ") action(" .. tostring(event.action) .. ") limitReached(" .. tostring(event.limitReached) .. ")")
        end

        -- Show the popup
        native.showPopup("social",
            {
                service = serviceName, -- The service key is ignored on Android.
                message = "Try Pong Fun!!",
                listener = listener,
                image =
                {--{ filename = "Icon.png", baseDir = system.ResourceDirectory },
                    --{ filename="Pong Fun Pitcture 1.png", baseDir=system.DocumentsDirectory},
                },
                url =
                {
                    "https://play.google.com/store/apps/details?id=com.gmail.khawarali5.pongFun",
                }
            })
        local function startPhysicsf()
            physics.start()
        end

        timer.performWithDelay(1000, startPhysicsf, 1)
        timer.resume(addBallTimer)

    else
        if isSimulator then
            native.showAlert("Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" })
        else
            -- Popup isn't available.. Show error message
            native.showAlert("Cannot send " .. serviceName .. " message.", "Please setup your " .. serviceName .. " account or check your network connection (on android this means that the package/app (ie Twitter) is not installed on the device)", { "OK" })
        end
        local function startPhysicsf()
            physics.start()
        end

        timer.performWithDelay(1000, startPhysicsf, 1)
        timer.resume(addBallTimer)
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then

    elseif phase == "did" then
        self.score = 0
        self.scoreText.text = self.score
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    --
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

---------------------------------------------------------------------------------

return scene
