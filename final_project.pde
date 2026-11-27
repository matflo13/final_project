/* //<>//
  -PIXEL PUNISHER-
  By: Matteo Florendo
  Final Processing Project
  Game Idea: Platformer x Arcade Beat em' up Game 
  SOURCES:
    Images:
      Player Assets: Primitive Pixels Games on itch.io
      Enemy Assets:https://admurin.itch.io/enemy-golem
      All other images made myself.
    Music: 
      Menu Music: https://pixabay.com/music/video-games-pixel-art-game-soundtrack-chiptune-588667/
      Battle Music:
      Game Over Music: 
      Sound Effects: Created myself using https://www.bfxr.net/
*/
import processing.sound.*;

// PImages
PImage devLogo;
PImage title;
PImage play;
PImage mainMenu;
PImage settings;
PImage leaderboard;
PImage info;
PImage player;
PImage ground;
PImage platform;
PImage enemy;
PImage effect;
PImage explosion;
PImage boxOne;
PImage boxTwo;
PImage exit;
int boxOneState = 1;
int boxTwoState = 1;

// Font

PFont pixelFont;

// Home Screen Variables
int gameState = 5; // 0: Home Screen 1: Gameplay 2: Game Over 3: Settings 4: Leaderboard 5: Intro/Dev Logo
float buttonSize = 1;
float wobble = 0;

// Player Variables
int playerX = 360;
int playerY = 320;
int playerDir = 90;
float playerMomentum = 0;
int playerWidth = 32;
int playerHeight = 32;
int playerHealth = 25;
boolean startAttack = false;
boolean isJumping = false;
boolean isAttacking = false;
boolean touchingGround = false;
String playerName;

int effectNum = 0;

// Enemy Variables
int enemyX = 900;
int enemyY = 414;
int enemyAnimTick;
int enemyDir = 90;
float enemyMomentum = 0;
float enemyMaxSpeed = 2;
int enemyMaxHealth = 10;
int enemyHealth = 10;
int enemyDamageTick = 0;
String enemyAction = "run";

int offset = 64; // Offset for the slashing effect from the player's sword

// Platform Variables
int platformX = 900;
int platformY = 368;
int platformWidth = 180;
int platformHeight = 30;
int gravity = 0;
int animTick; // Global tick variable for everything in the game
int playerAnimTick; // Animation tick for the player
int playerAnimLength = 10; // Length of the animation cycle that the player is currently using.
int groundAnimTick;
int groundHeight = 423;

// Music Variables

Sound vol; // Controls the volume of all the sounds in the project.
float musicVolume = 0.4; // Volume for the music in the project
float sfxVolume = 1.0; // Volume for the sound effects in the project
SoundFile homeMusic;
SoundFile battleMusic;
SoundFile gameOverMusic;
float bpm = 84.0; // This is the bpm of the home menu song. It's actually 168 bpm, but I made it halftime because I wanted the screen to flash every other beat instead of every beat.
float beatInterval = 60000.0 / bpm; // This calculates the exact amount of time in between each beat.
float nextBeatTime = 0;
int flash = 0; // Effect for the bg flash effect.

// Sound Effect Variables
SoundFile jumpSfx;
SoundFile attackSfx;
SoundFile hitSfx;
SoundFile explosionSfx;
SoundFile selectSfx;
SoundFile startSfx;

// Misc Variables
int score = 0;
int xp = 0;
int level = 1;
int nextLevelUp = 100;
boolean levelUp = false; 
boolean pause = false;

// Highscore List
IntList highscores = new IntList();
StringList names = new StringList();
boolean highscoreUpdate = false;

void setup() {
  size(900, 536);
  
  // CUSTOM FONT
  pixelFont = createFont("Font/pixel.ttf", 24);
  textFont(pixelFont);
  
  // LOGO
  devLogo = loadImage("dev-logo.png");
  
  // BUTTON IMAGES
  title = loadImage("Home Screen/title.png");
  play = loadImage("Home Screen/play.png");
  mainMenu = loadImage("Home Screen/main-menu.png");
  settings = loadImage("Home Screen/settings.png");
  leaderboard = loadImage("Home Screen/leaderboard.png");
  info = loadImage("Home Screen/info.png");
  
  // GAME IMAGES
  player = loadImage("Player/Run/player_run_90_0.png");
  ground = loadImage("ground_1.png");
  platform = loadImage("platform_1.png");
  enemy = loadImage("Enemy/Golem/Run/enemy_run_90_0.png");
  effect = loadImage("Player/FX/attack_effect_1_90_0.png");
  explosion = loadImage("Enemy/Golem/Death/effect_explosion_0.png");
  
  // SETTINGS IMAGES
  boxOne = loadImage("Settings/checked-box.png");
  boxTwo = loadImage("Settings/unchecked-box.png");
  exit = loadImage("Settings/exit.png");
  
  // MUSIC & SFX
  homeMusic = new SoundFile(this, "Music/homescreen.mp3");
  battleMusic = new SoundFile(this, "Music/battle.mp3");
  gameOverMusic = new SoundFile(this, "Music/game-over.mp3");
  jumpSfx = new SoundFile(this, "SFX/jump.wav");
  attackSfx = new SoundFile(this, "SFX/attack.wav");
  hitSfx = new SoundFile(this, "SFX/hit.wav");
  explosionSfx = new SoundFile(this, "SFX/explosion.wav");
  selectSfx = new SoundFile(this, "SFX/select.mp3");
  startSfx = new SoundFile(this, "SFX/start.mp3");
  vol = new Sound(this);
  // The first beat will trigger right when the game starts.
  nextBeatTime = millis(); 
  
  // IMAGE AND TEXT FORMATTING
  imageMode(CENTER);
  textAlign(CENTER);
  textSize(20);
  
  // HIGHSCORE LIST FORMATTING
  highscores.append(0);
  highscores.append(0);
  highscores.append(0);
  highscores.append(0);
  highscores.append(0);
  
  names.append("N/A");
  names.append("N/A");
  names.append("N/A");
  names.append("N/A");
  names.append("N/A");
  
  loadHighScores();
}
void draw() {
  
  // BACKGROUND
  background(61 + flash, 17 + flash, 41 + flash); // Background will update with the flash variable each time.

  if (flash > 0) {
      flash -= 1; // If the bg brightness is brighter than the base bg color, change it by -2.
  } else if (flash < 0) {
    flash += 1; // If the bg brightness is brighter than the base bg color, change it by -2.
  }
  
  if (gameState == 0) {
    
    vol.volume(1.0);
    homeMusic.amp(musicVolume);
    battleMusic.amp(musicVolume);
    playMusic(homeMusic, battleMusic, gameOverMusic); // Play main menu song
    
    // Check if millis() reached or passed the next beat
    if (millis() >= nextBeatTime) {
      flash = 20;
      nextBeatTime += beatInterval; // Adds the beat interval to nextBeatTime so that it will check for the next beat in the song.
    }
    
    // MAIN MENU LAYOUT
    
    // I did the wobble code in a Scratch project I made a while back, and I transferred the math to Processing. I don't completely remember how it works, but I remembered I had done it sometime in the past. 
    wobble += 0.08; // Here is the link to the project if you want to see the effect in action. https://scratch.mit.edu/projects/921255622/
    image(title, 450, 150 + (cos(wobble) * 4), 244, 96);
    image(ground, 512 - (groundAnimTick * 2), 24, 1024, 1024);
    int xpToNext = nextLevelUp - xp;
    strokeWeight(0.0);
    fill(49, 0, 34);
    textSize(24);
    fill(0);
    text("Matteo Studios 2026.", 453, 503);
    text("Lvl. " + level, 100, 53);
    textSize(18);
    text(xp + " XP", 100, 73);
    text("Next Level: " + xpToNext + "XP", 105, 93);
    fill(255);
    textSize(24);
    text("Matteo Studios 2026.", 450, 500);
    text("Lvl. " + level, 100, 50);
    textSize(18);
    text(xp + " XP", 100, 70);
    text("Next Level: " + xpToNext + "XP", 105, 90);
    
    // MAIN MENU GROUND SCROLLING
    
    animTick = millis() / 4; 
    groundAnimTick = (animTick / 9 % 16) + 1;
    
    // PLAY BUTTON

    if ((mouseX > 178 && mouseX < 422) && (mouseY > 227 && mouseY < 323)) {
      buttonSize = 1.03;
      if (mousePressed == true) {
        playSfx(selectSfx);
        gameState = 1;
      }
    } else {
      buttonSize = 1.0;
    }    
        
    image(play, 300, 275, 244 * buttonSize, 96 * buttonSize);
    
    // INFO BUTTON
    
    if ((mouseX > 826 && mouseX < 874) && (mouseY > 86 && mouseY < 134)) {
      buttonSize = 1.03;
      if (mousePressed == true) {
        playSfx(selectSfx);
        gameState = 6;
      }
    } else {
      buttonSize = 1.0;
    } 
    
    image(info, 850, 110, 244 * buttonSize, 96 * buttonSize);
    
    // SETTINGS BUTTON

    if ((mouseX > 478 && mouseX < 722) && (mouseY > 227 && mouseY < 323)) {
      buttonSize = 1.03;
      if (mousePressed == true) {
        playSfx(selectSfx);
        gameState = 3;
      }
    } else {
      buttonSize = 1.0;
    }       
    
    image(settings, 600, 275, 244 * buttonSize, 96 * buttonSize);
    
    // LEADERBOARD BUTTON
    
    if ((mouseX > 826 && mouseX < 874) && (mouseY > 26 && mouseY < 74)) {
      buttonSize = 1.05;
      if (mousePressed == true) {
        gameState = 4;
        playSfx(selectSfx);
      }
    } else {
      buttonSize = 1.0;
    }   
    
    image(leaderboard, 850, 50, 244 * buttonSize, 96 * buttonSize);
    
    // RESET VARIABLES
    // So that the game can reset the same way every time.
    playerHealth = 25;
    enemyMaxSpeed = 2;
    enemyMaxHealth = 10;
    enemyHealth = 10;
    enemyX = 900;
    enemyY = 414;
    playerX = 360;
    playerY = 320;
    playerDir = 90;
    playerMomentum = 0;
    score = 0;
    
  } else if (gameState == 1) {
    
    
    if (pause == false) {
      highscoreUpdate = false;
      vol.volume(0.5);
      playMusic(battleMusic, homeMusic, gameOverMusic); // Play battle music
      
      fill(250, 250, 250);
      if (isAttacking == true) {
        image(player, playerX, playerY, 100, 100);
        image(effect, playerX + offset, playerY, 128, 100);
      } else {
        image(player, playerX, playerY, 60, 60);
      }
      image(enemy, enemyX, enemyY, 128, 128);
      image(ground, 512 - (groundAnimTick * 2), 32, 1024, 1024);
      image(platform, platformX, platformY, 180, 30);
      textSize(24);
      text(enemyHealth + " HP", enemyX, enemyY - 32);
      text(playerHealth + " HP", playerX, playerY - 32);
      textSize(32);
      text("Score: " + score, 450, 100);
      fill(255, 255, 255);
      //rect(playerX - (playerWidth / 2), playerY - (playerHeight / 2), playerWidth, playerHeight); (PLAYER HITBOX) 
      //rect(platformX - (platformWidth / 2), platformY - (platformHeight / 2), platformWidth, platformHeight); (PLATFORM HITBOX)
      
      // TICK SCROLLING
      playerX -= 1; // Always moves the player to the left slowly to keep up with the scrolling ground.
      enemyX -= 1; // Same for enemies.
      platformX -= 1; // Same for the floating platform.
      
      // GRAVITY
      gravity += 1; // Player falls faster the longer they are in the air.
      playerY += gravity; // Updates the player's y value by gravity.
      
      // GROUND COLLISIONS
      if (playerY >= groundHeight) { // If the player is touching the ground:
        touchingGround = true;
        isJumping = false; // Player is not jumping.
        while (playerY >= groundHeight) { // Reset gravity and lift the player until the player isn't touching the ground.
          gravity = 0; // Set gravity to 0
          playerY -= 1; // Move the player up by 1y.
        }
      }
      
      // PLATFORM COLLISIONS
      int feet = playerY + (playerHeight / 2);
      int left = playerX - (playerWidth / 2);
      int right = playerX - (playerWidth / 2);
      int platformTop = platformY - (platformHeight / 2);
      int platformLeft = platformX - (platformWidth / 2) - 32;
      int platformRight = platformX + (platformWidth / 2);
      
      //rect(left, head, playerWidth, playerHeight); 
      //rect(platformLeft, platformTop, platformWidth, platformHeight);
      //if ((feet > platformTop) && (right > platformLeft) && (left < platformRight) && (head < platformBottom)) {
       // println("collision");
     // }
      if ((feet > platformTop) && (right > platformLeft) && (left < platformRight) && (gravity > 0)) {
        touchingGround = true;
        isJumping = false; // Player is not jumping.
        if (key != 's') {
          if (feet >= platformTop) { // Reset gravity and lift the player until the player isn't touching the ground.
            gravity = 0; // Set gravity to 0
            playerY -= 1; // Move the player up by 1y.
          } 
        }
      }
      
      // MOVEMENT CONTROLS
      //I did movement in the draw loop since the keyPressed function was giving a delay when a key was clicked.
      if ((keyPressed == true && key == 'w') && (touchingGround == true)) {
        gravity -= 17;
        isJumping = true; // Player is now jumping.
        touchingGround = false;
        playSfx(jumpSfx); // Only triggers when the player first jumps.
      }
        
      if (isJumping == false || gravity > 0) {
        if (isAttacking == false) {
          if ((keyPressed == true && key == 'a')) {
            playerDir = -90;
            if (playerMomentum > -8) {
              playerMomentum -= 1;
            }
          } else if ((keyPressed == true && key == 'd')) {
            playerDir = 90;
            if (playerMomentum < 8) {
              playerMomentum += 1;
            }
          } else if (abs(playerMomentum) < 0.5) {
            playerMomentum = 0;
          }
        }
      }
           
      // OUT OF BOUNDS CHECKS
      if (playerX < 0) {
        playerMomentum = 10;
        playerHealth -= 2;
        playSfx(hitSfx);
        flash = -20;
      } else if (playerX > 900) {
        playerMomentum = -10;
        playerHealth -= 2;
        playSfx(hitSfx);
        flash = -20;
      }
      
      // MOMENTUM CALCULATIONS
      playerX += playerMomentum;
      if (isJumping == false) {
        playerMomentum = playerMomentum * 0.87;
      }
      // ANIMATIONS
      /* 
        playerAnimTick sets the frame of the animation to display the player at. It's done using the millis() function, dividing it by 4 to slow 
        it down, and using modulus 4 (% 4) to make it constantly cycle through 4 values.
      */
      animTick = millis() / 4;
      playerAnimTick = (animTick / 16) % playerAnimLength; 
      groundAnimTick = (animTick / 9 % 16) + 1;
      /*
        Instead of loading the image right at the start, I do it every frame, while updating 
        the frame number so that the animation updates on the screen.
      */
      
      if (keyPressed == true && (key == 'a' || key == 'd' || keyCode == 37 || keyCode == 39) && gravity == 0 && isAttacking != true) {
        if (playerAnimTick > 9) {
          playerAnimTick = 0;
        }
        offset = 0;
        playerAnimLength = 10;
        player = loadImage("Player/Run/player_run_" + playerDir + "_" + playerAnimTick + ".png");
      } else if (gravity > 0) {
        if (playerAnimTick > 9) {
          playerAnimTick = 0;
        }
        offset = 0;
        playerAnimLength = 10;
        player = loadImage("Player/Fall/player_fall_" + playerDir + "_" + playerAnimTick + ".png");
      } else if (gravity < 0) {
        if (playerAnimTick > 12) {
          playerAnimTick = 0;
        }
        offset = 0;
        playerAnimLength = 13;
        player = loadImage("Player/Jump/player_jump_" + playerDir + "_" + playerAnimTick + ".png");
      } else if (startAttack == true) {
        if (isAttacking == false) {
          playerAnimTick = 0;
          isAttacking = true;
        }
        if (playerAnimTick > 7) {
          playerAnimTick = 0;
        }
        offset = (playerDir / 90 * 64);
        playerAnimLength = 8;
        player = loadImage("Player/Attack/player_attack_" + playerDir + "_" + playerAnimTick + ".png");
        effect = loadImage("Player/FX/attack_effect_" + effectNum + "_" + playerDir + "_" + playerAnimTick + ".png");
      } else {
        offset = 0;
        playerAnimLength = 24;
        player = loadImage("Player/Idle/player_idle_" + playerDir + "_" + playerAnimTick + ".png");
      }     
      
      // ATTACK RESET
      // Makes it so that the player can't just continously hold the mouse down to attack the enemy.
      if (enemyAction == "die" || enemyAction == "damage") {
        isAttacking = false;
        startAttack = false;
      }
      
      // PLAYER DEATH CHECK
      
      if (playerHealth == 0) {
        gameState = 2;
        playSfx(explosionSfx);
      }
      
      // PLATFORM SPAWNING
      
      if (platformX < -160) {
        platformX = 1000;
        platformY = int(random(304, 368));
      }
      
      // ENEMY MOVEMENT
      
      int distToPlayerX;
      int distToPlayerY;
      distToPlayerX = playerX - enemyX;
      distToPlayerY = playerY - enemyY;
      enemyX += enemyMomentum;
      if ((distToPlayerX < -3 || distToPlayerX > 3) && enemyDamageTick <= 0) {
        if (distToPlayerX < 0) {
          enemyMomentum = 0 - enemyMaxSpeed;
          enemyDir = -90;
          enemyAction = "run";
        } else {
          enemyMomentum = enemyMaxSpeed + 2;
          enemyDir = 90;
          enemyAction = "run";
        }
      } else {
        if ((distToPlayerY > -32 && distToPlayerY < 32) && enemyDamageTick <= 0) {
          enemyMomentum = 0;
          enemyAction = "attack";
          playSfx(hitSfx);
          if (enemyAnimTick > 2) {
            playerHealth -= 1;
            flash = -10;
            if (playerHealth < 1) {
              playerHealth = 0;
            }
          }
        } if (enemyDamageTick > 0) {
          enemyAction = "damage";
        }
      }
      
      if (abs(enemyMomentum) < 0.5) {
        enemyMomentum = 0;
      }
      enemyMomentum = enemyMomentum * 0.75;
      enemyDamageTick -= 1;
      
      // ENEMY DAMAGE CHECK
      
      if (isAttacking == true) {
        if (playerDir == -90 && (distToPlayerX > 0 && distToPlayerX < 64) && (playerAnimTick > 3 && playerAnimTick < 7) && (distToPlayerY < 32 && distToPlayerY > -32)) { // If this is true, the enemy is being attacked from the right side.
          enemyAction = "damage";
          enemyDir = 90;
          enemyMomentum = -7;
          enemyDamageTick = 30;
          flash = 10;
          score += 300;
          playSfx(hitSfx);
          if (enemyHealth > 0) {
            enemyHealth -= int(random(1, 4));
          }
        } else if (playerDir == 90 && (distToPlayerX < 0 && distToPlayerX > -64) && (playerAnimTick > 3 && playerAnimTick < 7) && (distToPlayerY < 32 && distToPlayerY > -32)) { // If this is true, the enemy is being attacked from the left side.
          enemyAction = "damage";
          enemyDir = -90;
          enemyMomentum = 15;
          enemyDamageTick = 30;
          flash = 10;
          score += 300;
          playSfx(hitSfx);
          if (enemyHealth > 0) {
            enemyHealth -= int(random(1, 4));
          }
        }
      }
      
      // ENEMY DEATH CHECK
      
      if (enemyHealth <= 0) {
        enemyMomentum = 0;
        score += 100;
        playSfx(explosionSfx);
        enemyAction = "die";
      }  
      
      
      // ENEMY ANIMATION
      if (enemyAction == "run") {
        enemyAnimTick = (animTick / 32) % 4;
        enemy = loadImage("Enemy/Golem/Run/enemy" + "_run_" + enemyDir + "_" + enemyAnimTick + ".png");
      } else if (enemyAction == "attack") {
        enemyAnimTick = (animTick / 16) % 10;
        enemy = loadImage("Enemy/Golem/Attack/enemy" + "_attack_" + enemyDir + "_" + enemyAnimTick + ".png");
      } else if (enemyDamageTick > 0) {
        enemyAnimTick = (animTick / 32) % 5;
        enemy = loadImage("Enemy/Golem/Damage/enemy" + "_damage_" + enemyDir + "_" + enemyAnimTick + ".png");
      } else if (enemyAction == "die") {
        enemyAnimTick = (animTick / 32) % 6;
        enemy = loadImage("Enemy/Golem/Death/" + "effect_explosion_" + enemyAnimTick + ".png");
        if (enemyAnimTick == 5) {
          enemyMaxSpeed += 0.5;
          enemyMaxHealth += int(random(5, 10));
          enemyHealth = enemyMaxHealth;
          enemyAction = "run";
          enemyX = (int(random(0, 1)) * 900);
        }
      }
    }  
  } else if (gameState == 2) {
    
    vol.volume(1.0);
    playMusic(gameOverMusic, battleMusic, homeMusic); // Play game over song
    
     // DRAW GAME OVER SCREEN
    stroke(251, 191, 91);
    strokeWeight(12);
    fill(81, 29, 54);
    rect(100, 50, 700, 440, 10);
    textSize(72);
    fill(0);
    text("GAME OVER", 450, 145);
    textSize(48);
    text("Score:" + score, 450, 250);
    textSize(72);
    fill(255);
    text("GAME OVER", 450, 140);
    textSize(48);
    text("Score:" + score, 450, 245);
    if (score == highscores.get(0)) {
      textSize(32);
      fill(0);
      text("New Highscore!", 450, 298);
      fill(255);
      text("New Highscore!", 450, 295);
    }
    if (levelUp == true) {
      textSize(32);
      fill(0);
      text("Level Up!", 450, 338);
      fill(255);
      text("Level Up!", 450, 335);
    }
    
    // UPDATE HIGHSCORE LIST AND LEVEL UP
    if (highscoreUpdate == false) {
      highscores.append(score); // Adds the score to the end of the highscore list
      highscores.sortReverse(); // Sorts the scores in the list from highest to lowest
      int index = highscores.index(score); // Index variable gets the list position of the current score so that the player name can be connected to the same spot in the name list
      names.insert(index, playerName); // Inserts the player name at the same position as their score
      saveHighScores();
      xp += score / 100;
      if (xp > nextLevelUp) {
        levelUp = true;
      } else {
        levelUp = false;
      }
      highscoreUpdate = true; // Sets the value to false so that it only updates one time when you die
    }
    
    if (xp > 99 && xp < 250) {
      effectNum = 2;
      level = 2;
      nextLevelUp = 250;
    } else if (xp > 249 && xp < 500) {
      effectNum = 3;
      level = 3;
      nextLevelUp = 500;
    } else if (xp > 499 && xp < 1000) {
      effectNum = 4;
      level = 4;
      nextLevelUp = 1000;
    } else if (xp > 999) {
      effectNum = 5;
      level = 5;
      nextLevelUp = 0;
    }
    
    // RESET VARIABLES
    // So that the game can reset the same way every time.
    playerHealth = 25;
    enemyMaxSpeed = 2;
    enemyMaxHealth = 10;
    enemyHealth = 10;
    enemyX = 900;
    enemyY = 414;
    playerX = 360;
    playerY = 320;
    playerDir = 90;
    playerMomentum = 0;
    pause = false;
    
    // PLAY BUTTON
    image(play, 300, 410, 244 * buttonSize, 96 * buttonSize);
    if ((mouseX > 478 && mouseX < 722) && (mouseY > 372 && mouseY < 458)) {
      buttonSize = 1.03;
      if (mousePressed == true) {
        playSfx(selectSfx);
        gameState = 0;
      }
    } else {
      buttonSize = 1.0;
    }    
    
    // HOME BUTTON
    image(mainMenu, 600, 410, 244 * buttonSize, 96 * buttonSize);
    if ((mouseX > 278 && mouseX < 422) && (mouseY > 372 && mouseY < 458)) {
      buttonSize = 1.03;
      if (mousePressed == true) {
        playSfx(startSfx);
        playerName = Ask.forString("Enter Player Name");
        gameState = 1;
        highscoreUpdate = false;
        score = 0;
      }
    } else {
      buttonSize = 1.0;
    }    
  } else if (gameState == 3) {
    
    // SETTINGS MENU
    
    // SCREEN DESIGN
    stroke(251, 191, 91);
    strokeWeight(12);
    fill(81, 29, 54);
    rect(100, 50, 700, 440, 10);
    textSize(48);
    fill(255);
    text("Volume", 450, 125);
    textSize(36);
    text("Music", 300, 200);
    text("SFX", 550, 200);

    // EXIT BUTTON
    image(exit, 765, 90, 128, 128);
    if ((mouseX > 750 && mouseX < 777) && (mouseY > 75 && mouseY < 105) && (mousePressed == true)) { // Button collision bounds are slightly bigger than the actual button so that the player can click the button more easily.
      playSfx(selectSfx);
      gameState = 0;
    }

    // MUSIC CHECKBOX
    image(boxOne, 400, 190, 244, 96);
    
    if (boxOneState == 1) {
      boxOne = loadImage("Settings/checked-box.png");
      musicVolume = 0.4;
      homeMusic.amp(musicVolume);
      battleMusic.amp(musicVolume);
    } else if (boxOneState == 0){
      boxOne = loadImage("Settings/unchecked-box.png");
      musicVolume = 0.0;
      homeMusic.amp(musicVolume);
      battleMusic.amp(musicVolume);
    }
    
    // SFX CHECKBOX
    image(boxTwo, 630, 190, 244, 96);
    
    if (boxTwoState == 1) {
      boxTwo = loadImage("Settings/checked-box.png");
      sfxVolume = 1.0;
      attackSfx.amp(sfxVolume);
      hitSfx.amp(sfxVolume);
      jumpSfx.amp(sfxVolume);
      explosionSfx.amp(sfxVolume);
    } else {
      boxTwo = loadImage("Settings/unchecked-box.png");
      sfxVolume = 0.0;
      attackSfx.amp(sfxVolume);
      hitSfx.amp(sfxVolume);
      jumpSfx.amp(sfxVolume);
      explosionSfx.amp(sfxVolume);
    }
  } else if (gameState == 4) {
    
    // LEADERBOARD
    
    // SCREEN DESIGN
    stroke(251, 191, 91);
    strokeWeight(12);
    fill(81, 29, 54);
    rect(100, 50, 700, 440, 10);
    
    // PRINT LEADERBOARD
    textSize(48);
    fill(0);
    text("Leaderboard", 450, 128);
    textSize(32);
    text("1.   " + names.get(0) + "   " + highscores.get(0), 450, 228);
    text("2.   " + names.get(1) + "   " + highscores.get(1), 450, 263);
    text("3.   " + names.get(2) + "   " + highscores.get(2), 450, 298);
    text("4.   " + names.get(3) + "   " + highscores.get(3), 450, 333);
    text("5.   " + names.get(4) + "   " + highscores.get(4), 450, 368);
    textSize(48);
    fill(255);
    text("Leaderboard", 450, 125);
    textSize(32);
    text("1.   " + names.get(0) + "   " + highscores.get(0), 450, 225);
    text("2.   " + names.get(1) + "   " + highscores.get(1), 450, 260);
    text("3.   " + names.get(2) + "   " + highscores.get(2), 450, 295);
    text("4.   " + names.get(3) + "   " + highscores.get(3), 450, 330);
    text("5.   " + names.get(4) + "   " + highscores.get(4), 450, 365);
    
    // EXIT BUTTON
    image(exit, 765, 90, 128, 128);
    if ((mouseX > 750 && mouseX < 777) && (mouseY > 75 && mouseY < 105) && (mousePressed == true)) {
      playSfx(selectSfx);
      gameState = 0;
    }
    
  } else if (gameState == 5) {
    
    // DEV LOGO/STARTUP SCREEN
    
    background(0);
    wobble += 0.08; // Here is the link to the project if you want to see the effect in action. https://scratch.mit.edu/projects/921255622/
    image(devLogo, 450, 270 + (cos(wobble) * 4), 256, 256);
    if (millis() < 2110) {
      playSfx(startSfx);
    }
    
    if (millis() > 5000) {
      gameState = 0;
    }
  } else if (gameState == 6) {
    
    // SCREEN DESIGN
    stroke(251, 191, 91);
    strokeWeight(12);
    fill(81, 29, 54);
    rect(100, 50, 700, 440, 10);
    textSize(48);
    fill(255);
    text("How to Play", 450, 175);
    textSize(24);
    text("A & D to move.", 450, 215);
    text("W to jump.", 450, 240);
    text("S to drop through platforms.", 450, 265);
    text("Hold left-click to attack.", 450, 290);
    text("Your attack will stop when you hit an enemy.", 450, 315);
    text("Stop holding the mouse to regain your attack.", 450, 340);
    
    // EXIT BUTTON
    image(exit, 765, 90, 128, 128);
    if ((mouseX > 750 && mouseX < 777) && (mouseY > 75 && mouseY < 105) && (mousePressed == true)) { // Button collision bounds are slightly bigger than the actual button so that the player can click the button more easily.
      playSfx(selectSfx);
      gameState = 0;
    }
  }
}

void mousePressed() {
  if (gameState == 1) {
    if (isJumping == false) {
      startAttack = true;
      playSfx(attackSfx); // Triggers only when the attack starts
    } else {
      isAttacking = false;
    }
  } else if (gameState == 3) {
    
    // MUSIC CHECKBOX CLICK CHECK
    if (mousePressed == true && (mouseX > 380 && mouseX < 420) && (mouseY > 170 && mouseY < 210)) {
      if (boxOneState == 1) {
        boxOneState = 0;
      } else {
        boxOneState = 1;
      }
    }
    
    // SFX CHECKBOX CLICK CHECK
    if (mousePressed == true && (mouseX > 610 && mouseX < 650) && (mouseY > 170 && mouseY < 210)) {
      if (boxTwoState == 1) {
        boxTwoState = 0;
      } else {
        boxTwoState = 1;
      }
    }
  }
}


void mouseReleased() {
  isAttacking = false;
  startAttack = false;
}

// Function that is used to stop the other two tracks I don't want to play, and to loop the one I do want to play.
void playMusic(SoundFile trackToPlay, SoundFile trackToStopOne, SoundFile trackToStopTwo) {
  if (trackToStopOne.isPlaying() || trackToStopTwo.isPlaying()) {
    trackToStopOne.stop();
    trackToStopTwo.stop();
  }
  if (!trackToPlay.isPlaying()) {
    trackToPlay.loop();
  }
}

void playSfx(SoundFile sfx) {
  sfx.amp(sfxVolume);
  sfx.play();
}

void saveHighScores() {
  JSONObject root = new JSONObject();
  
  // Saves the two lists into the highscores JSON file.
  root.setJSONArray("names", new JSONArray(names));
  root.setJSONArray("scores", new JSONArray(highscores));
  
  saveJSONObject(root, "data/highscores.json");
}

void loadHighScores() {

  JSONObject root = loadJSONObject("data/highscores.json");
  
  // Converts the arrays in the JSON file into the StringList and IntList that I use in Processing to store highscores.
  names = root.getJSONArray("names").toStringList(); // toStringList() converts the names array into a StringList.
  highscores = root.getJSONArray("scores").toIntList(); // toIntList() converts the scores array into a IntList.
}
