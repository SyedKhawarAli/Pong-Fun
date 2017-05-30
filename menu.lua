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

-- Initialize Google Analytics
-- Load scene with same root filename as this file
local scene = composer.newScene(sceneName)
local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

local gameNetwork = require "gameNetwork"
-- Init game network to use Google Play game services
gameNetwork.init("google")

local leaderboard1Id = "" -- Your leaderboard id here
local leaderboard2Id = "" -- Your leaderboard id here

local achievement1Id = "" -- Your achievement id here
local achievement2Id = "" -- Your achievement id here
local achievement3Id = "" -- Your achievement id here
local achievement4Id = "" -- Your achievement id here
local achievement5Id = "" -- Your achievement id here

-- Tries to automatically log in the user without displaying the login screen if the user doesn't want to login
gameNetwork.request("login",
    {
        userInitiated = false
    })

---------------------------------------------------------------------------------
function scene:create(event)
    local sceneGroup = self.view

    local bgRect = display.newRect(_CX, _CY, _W, _H)
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
            sounds.playStream('menu_music')
        end
    })
    musicButtons.off.anchorX, musicButtons.off.anchorY = 0, 0
    sceneGroup:insert(musicButtons.off)
    table.insert(visualButtons, musicButtons.off)

    updateDataboxAndVisibility()
    sounds.playStream('menu_music')

    ----------------------------------------------------------
    local myText = display.newText("Pong Fun", _CX, _H / 4 * 1 - 13, native.systemFont, 89)
    myText:setFillColor(1, 1, 1, 1)
    myText.anchorX, myText.anchorY = 0.5, 0
    sceneGroup:insert(myText)

    self.score = display.newText("Score: ", _CX, _H / 4 * 1 + _H / 8, native.systemFont, 46)
    self.score:setFillColor(1, 1, 1, 1)
    --score.anchorX,score.anchorY= 0.5,1

    sceneGroup:insert(self.score)

    self.highScore = display.newText("High Score: ", _CX, _H / 4 * 1 + _H / 8 + _H / 21, native.systemFont, 46)
    self.highScore:setFillColor(1, 1, 1, 1)
    --highScore.anchorX,highScore.anchorY= 0.5,1

    sceneGroup:insert(self.highScore)

    self.gamePlayed = display.newText("Games Played: ", _CX, _H / 4 * 1 + _H / 8 + _H / 21 + _H / 21, native.systemFont, 46)
    self.gamePlayed:setFillColor(1, 1, 1, 1)
    sceneGroup:insert(self.gamePlayed)

    local play = widget.newButton({
        defaultFile = 'play.png',
        overFile = 'play-over.png',
        x = _CX,
        y = _H / 4 * 2 + _H / 8,
        onRelease = function()
            sounds.play('tap')
            databox.gamePlayed = databox.gamePlayed + 1
            --self:congPopup()
            composer.gotoScene("reload")
        end
    })
    --play.anchorX,play.anchorY= 0,0
    sceneGroup:insert(play)

    ----------------------------------------------------------- share --------------------------------------



    --    if "simulator" == system.getInfo("environment") then
    --        native.showAlert("Build for device", "This plugin is not supported on the Corona Simulator.", { "OK" })
    --    end

    -- Require the widget library
    local widget = require("widget")

    -- Use the Android "Holo Dark" theme for this sample
    widget.setTheme("widget_theme_android_holo_dark")

    -- Display some text
    --[[local achievementText = display.newText{
        text = "You saved the planet!\n\nTouch any of the buttons below to share your victory with your friends!",
        x = display.contentCenterX,
        y = 60,
        width = display.contentWidth - 20,
        height = 0,
        font = native.systemFont,
        fontSize = 18,
        align = "center"
    }]]

    -- Executed upon touching and releasing the button created below
    local function onShareButtonReleased(event)
        local serviceName = event.target.id
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
                    {
                        { filename = "Icon.png", baseDir = system.ResourceDirectory },
                    },
                    url =
                    {
                        "https://play.google.com/store/apps/details?id=com.gmail.khawarali5.pongFun",
                    }
                })
        else
            if isSimulator then
                native.showAlert("Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" })
            else
                -- Popup isn't available.. Show error message
                native.showAlert("Cannot send " .. serviceName .. " message.", "Please setup your " .. serviceName .. " account or check your network connection (on android this means that the package/app (ie Twitter) is not installed on the device)", { "OK" })
            end
        end
    end



    local function requestCallback()
        print("loged in ")
        native.showAlert("Success!", "User has logged into Game Center", { "OK" })
    end

    local share = widget.newButton({
        id = "share",
        defaultFile = 'share.png',
        overFile = 'share-over.png',
        x = _W / 7 * 2,
        y = _H / 4 * 3,
        onRelease = onShareButtonReleased
    })
    share.anchorX, share.anchorY = 0.5, 0
    sceneGroup:insert(share)

    ------------------------------------------------------------------------
    local function showLeaderboardListener(event)
        gameNetwork.show("leaderboards") -- Shows all the leaderboards.
    end

    local function showAchievementsListener(event)
        gameNetwork.show("achievements") -- Shows the locked and unlocked achievements.
    end

    ---------------------------------------------------------------------- LB --------------------------------------
    local twitter = widget.newButton({
        defaultFile = 'LB.png',
        overFile = 'LB-over.png',
        x = _W / 7 * 3,
        y = _H / 4 * 3,
        onRelease = function()
            sounds.play('tap')
            showLeaderboardListener()
            --system.openURL( "https://twitter.com/uet_game_lab" )
        end
    })
    twitter.anchorX, twitter.anchorY = 0.5, 0
    sceneGroup:insert(twitter)
    ---------------------------------------------------------------------- achivements --------------------------------------

    local fb = widget.newButton({
        defaultFile = 'achivements.png',
        overFile = 'achivements-over.png',
        x = _W / 7 * 4,
        y = _H / 4 * 3,
        onRelease = function()
            sounds.play('tap')
            showAchievementsListener()
            --system.openURL( "https://www.facebook.com/uetgamelab/")
        end
    })
    fb.anchorX, fb.anchorY = 0.5, 0
    sceneGroup:insert(fb)
    ---------------------------------------------------------------------- rate --------------------------------------
    local function rateIt()
        local deviceType = system.getInfo("platformName")
        local deviceVersion = system.getInfo("platformVersion")

        local appleAppID = "XXXXXXXXX"
        local googleAppID = "com.gmail.khawarali5.pongFun"

        local urlPrefix = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="
        local urlSuffix = "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

        if deviceType == "iPhone OS" then

            if string.find(deviceVersion, "7.0") then
                system.openURL("itms-apps://itunes.apple.com/app/id" .. appleAppID)
            else
                system.openURL(urlPrefix .. appleAppID .. urlSuffix)
            end

        elseif deviceType == "Android" then

            system.openURL("https://play.google.com/store/apps/details?id=" .. googleAppID)
        end
    end


    local rate = widget.newButton({
        defaultFile = 'rate.png',
        overFile = 'rate-over.png',
        x = _W / 7 * 5,
        y = _H / 4 * 3,
        onRelease = function()
            sounds.play('tap')
            rateIt()
        end
    })
    rate.anchorX, rate.anchorY = 0.5, 0
    sceneGroup:insert(rate)


    --------------------------------------------------- log in try for google play services ---------------------------------------
    local function loginListener(event1)
        -- Checks to see if there was an error with the login.
        if event1.isError then
            --loginLogoutButton:setLabel("Login")
        else
            --loginLogoutButton:setLabel("Logout")
        end
    end

    if gameNetwork.request("isConnected") then
        --gameNetwork.request("logout")
        --loginLogoutButton:setLabel("Login")
    else
        -- Tries to login the user, if there is a problem then it will try to resolve it. eg. Show the log in screen.
        gameNetwork.request("login",
            {
                listener = loginListener,
                userInitiated = true
            })
    end
    --------------------------------------------------------------
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        self.score.text = "Score: " .. databox.score
        self.highScore.text = "High Score: " .. databox.highScore
        self.gamePlayed.text = "Games Played: " .. databox.gamePlayed

        if gameNetwork.request("isConnected") then
            ----------------------- set high score ------------------
            gameNetwork.request("setHighScore",
                {
                    localPlayerScore =
                    {
                        category = leaderboard1Id, -- Id of the leaderboard to submit the score into
                        value = databox.highScore --scoreTextField.text -- The score to submit
                    }
                })
            ----------------------------- set games played -------------------
            gameNetwork.request("setHighScore",
                {
                    localPlayerScore =
                    {
                        category = leaderboard2Id, -- Id of the leaderboard to submit the score into
                        value = databox.gamePlayed --scoreTextField.text -- The score to submit
                    }
                })
            ------------------------------ achivements unlocked ----------------------------
            if (databox.score >= 20) then
                gameNetwork.request("unlockAchievement",
                    {
                        achievement =
                        {
                            identifier = achievement1Id -- The id of the achievement to unlock for the current user
                        }
                    })
            end
            ----------------------------- 2 -----------------
            if (databox.score >= 40) then
                gameNetwork.request("unlockAchievement",
                    {
                        achievement =
                        {
                            identifier = achievement2Id -- The id of the achievement to unlock for the current user
                        }
                    })
            end
            ------------------------ 3 ---------------
            if (databox.score >= 60) then
                gameNetwork.request("unlockAchievement",
                    {
                        achievement =
                        {
                            identifier = achievement3Id -- The id of the achievement to unlock for the current user
                        }
                    })
            end
            ---------------------- 4 ---------
            if (databox.score >= 80) then
                gameNetwork.request("unlockAchievement",
                    {
                        achievement =
                        {
                            identifier = achievement4Id -- The id of the achievement to unlock for the current user
                        }
                    })
            end
            -------------------- 5 ----------------
            if (databox.score >= 100) then
                gameNetwork.request("unlockAchievement",
                    {
                        achievement =
                        {
                            identifier = achievement5Id -- The id of the achievement to unlock for the current user
                        }
                    })
            end
            ---------------------------------------
            -- loginLogoutButton:setLabel("Logout")
        end

    elseif phase == "did" then




        function initCB(event)
            if not event.isError then
                toast.show('submitted score')
                print('submitted score')
            else
                toast.show('not submitted score')
                print('NOT submitted score')
                print(event.errorMessage)
            end
        end
    end
end


function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
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
