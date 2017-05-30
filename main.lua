---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
-- require the composer library
local composer = require "composer"
local widget = require('widget')


local relayout = require "libs.relayout"
local color = require "libs.convertcolor"
local sounds = require('libs.sounds')
local physics = require "physics"
local databox = require('libs.databox')


display.setStatusBar( display.HiddenStatusBar )
composer.recycleOnSceneChange = true -- Automatically remove scenes from memory
--physics.setDrawMode( "hybrid" ) 
physics.start()
databox({
    isMusicOn = true,
    score = 0,
    highScore = 0,
    gamePlayed=0
})
databox.score = 0
sounds.isMusicOn = databox.isMusicOn

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)


-- Add any system wide event handlers, location, key events, system resume/suspend, memory, etc.

-- load scene1
composer.gotoScene( "menu" )
