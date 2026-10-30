/*
  Matteo Florendo 
  Final Processing Project
  Game Idea: Platformer/Geometry Dash
  TODO: 
    Make a basic platforming engine with:
      - Left/right movement
      - Jumping with gravity
      - Floor Collisions
    Design pixel art character    
*/

PImage player;
PImage spike;
PImage ground;
int playerX = 360;
int playerY = 370;
int playerDir = 90;
int spikeX = 720;
int spikeY = 385;
boolean spikeSpawned = false;
int gravity = 0;
int animTick; // Global tick variable for everything in the game
int playerAnimTick; // Animation tick for the player
int spikeAnimTick; // Animation tick for spikes
int groundAnimTick;
int level; // Level 1: Grass | Level 2: Underground
void setup() {
  size(720, 540);
  player = loadImage("player_90_0.png");
  spike = loadImage("spike.png");
  ground = loadImage("ground_1.png");
  imageMode(CENTER);
}
void draw() {
  background(121, 26, 67);
  fill(64, 5, 18);
  //rect(0, 400, 720, 170);
  image(player, playerX, playerY, 128, 128);
  image(ground, 512 - (groundAnimTick * 4), 92, 1024, 1024);
  
  // TICK PLAYER MOVEMENT
  // playerX += playerDir / 18;
  // GRAVITY
  gravity += 1; // Player falls faster the longer they are in the air.
  playerY += gravity; // Updates the player's y value by gravity.
  playerX -= 1;
  
  // FLOOR COLLISIONS
  if (playerY >= 380) { // If the player is touching the ground:
    while (playerY >= 380) { // Reset gravity and lift the player until the player isn't touching the ground.
      gravity = 0; // Set gravity to 0
      playerY -= 1; // Move the player up by 1y.
    }
  }
  
  // ANIMATIONS
  /* 
    playerAnimTick sets the frame of the animation to display the player at. It's done using the millis() function, dividing it by 4 to slow 
    it down, and using modulus 4 (% 4) to make it constantly cycle through 4 values.
  */
  animTick = millis() / 4;
  playerAnimTick = animTick % 4; 
  spikeAnimTick = ((animTick / 4) % 16); 
  groundAnimTick = (animTick / 16 % 16) + 1;
  /*
    Instead of loading the image right at the start, I do it every frame, while updating 
    the frame number so that the animation updates on the screen.
  */
  player = loadImage("player_" + playerDir + "_" + playerAnimTick + ".png");
  spike = loadImage("spike_" + spikeAnimTick + ".png");
  
  // SPIKE SPAWNING
  if ((random(1, 10) == 1)) {
    spikeSpawned = true;
    spawnSpike();
  }
  
  if (spikeSpawned = true) {
    image(spike, spikeX, spikeY, 96, 96);
    spikeX -= 5;
  }
}
void keyPressed() {
  if (key == 'a') {
    playerDir = -90;
    playerX -= 8;
  } else if (key == 'd') {
    playerDir = 90;
    playerX += 8;
  }
  if (key == 'w') {
    gravity -= 15;
  }
}

void spawnSpike() {
  spikeX = 720;
  spikeY  = 389;
}
