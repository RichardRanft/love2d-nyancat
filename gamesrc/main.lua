require "logging"
require "nyancatgame"
require "background"
require "nyancat"
require "utilities"
require "spritesheet"
require "nyancatparticles"

logging.LOGACTIVE = true;
logging.LOGTOCONSOLE = true;
logging.LOGFILEPATH = "game.log";
logging.LOGLEVEL = 3; -- 1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG

SCRIPTNAME = "main.lua";

function love.load()
   logging.DEBUG("Nyancat Game started at " .. os.date("%Y-%m-%d %H:%M:%S"), SCRIPTNAME);
   NYANCATGAME.GAMESTATE = "menu";
   newGameBtnImg = love.graphics.newImage("assets/images/nyanButton1NewNorm.png");
   quitBtnImg = love.graphics.newImage("assets/images/nyanButton1QuitNorm.png");
   hoverBtnImg = love.graphics.newImage("assets/images/nyanButton1.png");
   table.insert(NYANCATGAME.menuOptions, NYANCATGAME.createButton("Start Game", 120, 300, newGameBtnImg:getWidth(), newGameBtnImg:getHeight(), newGameBtnImg, hoverBtnImg, function() NYANCATGAME.GAMESTATE = "start"; end));
   table.insert(NYANCATGAME.menuOptions, NYANCATGAME.createButton("Quit", 120, 380, quitBtnImg:getWidth(), quitBtnImg:getHeight(), quitBtnImg, hoverBtnImg, function() love.event.quit(); end));
   selectedOption = 1;
   font = love.graphics.newFont(25);
   menuBGImg = love.graphics.newImage("assets/images/nyanBackground.png");
   gameBGImg = love.graphics.newImage("assets/images/NightSkyBG.png");
   NYANCATGAME.menuBGScaleX, NYANCATGAME.menuBGScaleY = NYANCATGAME.getImgScaling(menuBGImg);
   NYANCATGAME.gameBGScaleX, NYANCATGAME.gameBGScaleY = NYANCATGAME.getImgScaling(gameBGImg);
   local windowWidth, windowHeight = love.graphics.getDimensions();
   logging.DEBUG("Initial window size: " .. windowWidth .. "x" .. windowHeight, SCRIPTNAME);
   BACKGROUND.load();
   love.window.setMode(windowWidth, windowHeight, {resizable=true, vsync=true});
   love.window.setTitle("Nyancat Game");
end

function love.draw()
   if NYANCATGAME.GAMESTATE == "menu" then
      NYANCATGAME.drawMenu();
   elseif NYANCATGAME.GAMESTATE == "start" then
      NYANCATGAME.startGame();
   elseif NYANCATGAME.GAMESTATE == "game" then
      NYANCATGAME.drawGame();
   end
end

function love.mousereleased(x, y, button)
   if NYANCATGAME.GAMESTATE == "menu" then
      for i, option in ipairs(NYANCATGAME.menuOptions) do
         if option.isHovered then
            option.action();
         end
      end
   end
end

function love.mousepressed(x, y, button)
   -- Handle mouse press events if needed
   if NYANCATGAME.GAMESTATE == "game" then
      NYANCATGAME.testHit(x, y);
   end
end

function love.keypressed(key)
   if NYANCATGAME.GAMESTATE == "menu" then
      if key == "up" then
         selectedOption = math.max(1, selectedOption - 1);
      elseif key == "down" then
         selectedOption = math.min(#NYANCATGAME.menuOptions, selectedOption + 1);
      elseif key == "return" then
         if selectedOption == 1 then
            NYANCATGAME.GAMESTATE = "start";
         else
            logging.DEBUG("Quitting game...", SCRIPTNAME);
            NYANCATGAME.quitGame();
            love.event.quit();
         end
      end
   end
   if key == "escape" then
      if NYANCATGAME.GAMESTATE == "game" then
         logging.DEBUG("Returning to menu...", SCRIPTNAME);
         NYANCATGAME.leaveGame();
         NYANCATGAME.GAMESTATE = "menu";
      else
         logging.DEBUG("Quitting game...", SCRIPTNAME);
         NYANCATGAME.quitGame();
         love.event.quit();
      end
   end
   if key == "up" then
      if NYANCATGAME.bgmSource and NYANCATGAME.bgmSource:isPlaying() then
         local currentVolume = NYANCATGAME.bgmSource:getVolume();
         NYANCATGAME.bgmSource:setVolume(math.min(1, currentVolume + 0.1));
         logging.DEBUG("Increased volume to " .. NYANCATGAME.bgmSource:getVolume(), SCRIPTNAME);
      end
   end
   if key == "down" then
      if NYANCATGAME.bgmSource and NYANCATGAME.bgmSource:isPlaying() then
         local currentVolume = NYANCATGAME.bgmSource:getVolume();
         NYANCATGAME.bgmSource:setVolume(math.max(0, currentVolume - 0.1));
         logging.DEBUG("Decreased volume to " .. NYANCATGAME.bgmSource:getVolume(), SCRIPTNAME);
      end
   end
end

function love.update(dt)
   if NYANCATGAME.GAMESTATE == "menu" then
      local mouseX, mouseY = love.mouse.getPosition();
      for i, option in ipairs(NYANCATGAME.menuOptions) do
         option.isHovered = mouseX >= option.x and mouseX <= option.x + option.width and mouseY >= option.y and mouseY <= option.y + option.height;
      end
   elseif NYANCATGAME.GAMESTATE == "game" then
      NYANCATGAME.update(dt);
   end
end