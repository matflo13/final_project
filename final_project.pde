/*
  Matteo Florendo 
  Final Processing Project
  Game Idea: Platformer/Geometry Dash
  TODO: 
    Fix attacking animation   
  SOURCES:
    Primitive Pixels Games on itch.io for player assets
    https://admurin.itch.io/enemy-golem for enemy assets
    I made all other pixel art
*/

PImage player;
PImage spike;
PImage ground;
PImage platform;
PImage enemy;
PImage effect;
int enemyX = 600;
int enemyY = 414;
int playerX = 360;
int playerY = 320;
int playerDir = 90;
float playerMomentum = 0;
int playerWidth = 32;
int playerHeight = 32;
boolean isJumping = false;
boolean isAttacking = false;
boolean touchingGround = false;
int offset = 64;
int spikeX = 720;
int spikeY = 385;
boolean spikeSpawned = false;
int platformX = 900;
int platformY = 368;
int platformWidth = 180;
int platformHeight = 30;
int gravity = 0;
int animTick; // Global tick variable for everything in the game
int playerAnimTick; // Animation tick for the player
int playerAnimLength = 10; // Length of the animation cycle that the player is currently using.
int spikeAnimTick; // Animation tick for spikes
int groundAnimTick;
int enemyAnimTick;
int enemyDir = 90;
float enemyMomentum = 0;
int enemyHealth = 100;
int enemyDamageTick = 0;
int groundHeight = 423;
void setup() {
  size(900, 540);
  player = loadImage("Player/Run/player_run_90_0.png");
  spike = loadImage("spike.png");
  ground = loadImage("ground_1.png");
  platform = loadImage("platform_1.png");
  enemy = loadImage("Enemy/Golem/Run/enemy_run_90_0.png");
  effect = loadImage("Player/FX/attack_effect_90_0.png");
  imageMode(CENTER);
  textAlign(CENTER);
  textSize(20);
}
void draw() {
  background(61, 17, 41);
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
  text(enemyHealth, enemyX, enemyY - 32);
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
  int head = playerY - (playerHeight / 2);
  int left = playerX - (playerWidth / 2);
  int right = playerX - (playerWidth / 2);
  int platformBottom = platformY + (platformHeight / 2);
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
  spikeAnimTick = (animTick / 4) % 16; 
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
  } else if (isAttacking == true) {
    if (playerAnimTick > 7) {
      playerAnimTick = 0;
    }
    offset = (playerDir / 90 * 64);
    playerAnimLength = 8;
    player = loadImage("Player/Attack/player_attack_" + playerDir + "_" + playerAnimTick + ".png");
    effect = loadImage("Player/FX/attack_effect_" + playerDir + "_" + playerAnimTick + ".png");
  } else {
    offset = 0;
    playerAnimLength = 24;
    player = loadImage("Player/Idle/player_idle_" + playerDir + "_" + playerAnimTick + ".png");
  } 
  
  spike = loadImage("spike_" + spikeAnimTick + ".png");
  
  // PLATFORM SPAWNING
  
  if (platformX < -160) {
    platformX = 1000;
    platformY = int(random(304, 368));
  }
  // SPIKE SPAWNING
  /*if ((random(1, 10) == 1)) {
    spikeSpawned = true;
    spawnSpike();
  }
  
  if (spikeSpawned = true) {
    image(spike, spikeX, spikeY, 96, 96);
    spikeX -= 5;
  } */
  
  // ENEMY MOVEMENT
  
  int distToPlayerX;
  int distToPlayerY;
  String enemyAction = "run";
  distToPlayerX = playerX - enemyX;
  distToPlayerY = playerY - enemyY;
  enemyX += enemyMomentum;
  if ((distToPlayerX < -3 || distToPlayerX > 3) && enemyDamageTick <= 0) {
    if (distToPlayerX < 0) {
      enemyMomentum = -2;
      enemyDir = -90;
      enemyAction = "run";
    } else {
      enemyMomentum = 4;
      enemyDir = 90;
      enemyAction = "run";
    }
  } else {
    if ((distToPlayerY > -32 && distToPlayerY < 32) && enemyDamageTick <= 0) {
      enemyMomentum = 0;
      enemyAction = "attack";
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
    if (playerDir == -90 && distToPlayerX > 0 && distToPlayerX < 128 && playerAnimTick > 3 && playerAnimTick < 7) { // If this is true, the enemy is being attacked from the right side.
      enemyAction = "damage";
      enemyDir = 90;
      enemyMomentum = -15;
      enemyHealth -= 1;
      enemyDamageTick = 30;
    } else if (playerDir == 90 && distToPlayerX < 0 && distToPlayerX > -128 && playerAnimTick > 3 && playerAnimTick < 7) { // If this is true, the enemy is being attacked from the left side.
      enemyAction = "damage";
      enemyDir = -90;
      enemyMomentum = 15;
      enemyHealth-= 1;
      enemyDamageTick = 30;
    }
  }
  
  // ENEMY ANIMATION
  if (enemyAction == "run") {
    enemyAnimTick = (animTick / 32) % 4;
    enemy = loadImage("Enemy/Golem/Run/enemy" + "_run_" + enemyDir + "_" + enemyAnimTick + ".png");
  } else if (enemyAction == "attack") {
    enemyAnimTick = (animTick / 16) % 10;
    enemy = loadImage("Enemy/Golem/Attack/enemy" + "_attack_" + enemyDir + "_" + enemyAnimTick + ".png");
  } else if (enemyDamageTick > 0) {
    enemyAnimTick = (animTick / 32) % 5; //<>//
    enemy = loadImage("Enemy/Golem/Damage/enemy" + "_damage_" + enemyDir + "_" + enemyAnimTick + ".png");
  }
}

void mousePressed() {
  if (isJumping == false) {
    isAttacking = true;
  } else {
    isAttacking = false;
  }
}

void mouseReleased() {
  isAttacking = false;
}

void spawnSpike() {
  spikeX = 720;
  spikeY  = 389;
}
