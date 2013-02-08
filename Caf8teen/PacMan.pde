/**
 * Copyright 2012 Facebook, Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

import java.util.Vector;

/**
 * Pac-Man!  With ghosts!
 * Written by Kieren Davies and Kosie van der Merwe
 */
class PacMan extends LXPattern {
  
  class Sprite {
    
    int[][] frames;
    int totalFrames;
    int width, height;
    int currFrame;
    int xPos, yPos, xInvVel, yInvVel, animInvVel;
    int moveDelay, animDelay;
    
    public Sprite(int[][] frames, int w, int h, int x, int y) {
      this.frames = frames;
      totalFrames = frames.length;
      width = w;
      height = h;
      xPos = x;
      yPos = y;
      xInvVel = 0;
      animInvVel = 1;
      moveDelay = 0;
      animDelay = 0;
    }
    
    public int getX() {
      return xPos;
    }
    
    public void setPos(int x, int y) {
      xPos = x;
      yPos = y;
    }
    
    public void setXInvVel(int x) {
      xInvVel = x;
    }
    
    public void setAnimInvVel(int v) {
      animInvVel = v;
    }
    
    public void run() {
      //draw
      PImage img = spritesheet.get(frames[currFrame][0], frames[currFrame][1], width, height);
      for (int x = 0; x < width; ++x) {
        if (x + xPos < 0 || lx.width <= x + xPos) continue;
        for (int y = 0; y < height; ++y) {
          if (y + yPos < 0 || lx.height <= y + yPos) continue;
          if (img.get(x, y) == transparent) continue;
          setColor(x + xPos, y + yPos, img.get(x, y));
        }
      }
      //advance frame
      if (++animDelay == animInvVel) {
        ++currFrame;
        currFrame %= totalFrames;
        animDelay = 0;
      }
      //move
      if (xInvVel > 0 && ++moveDelay == xInvVel) {
        ++xPos;
        moveDelay = 0;
      } else if (xInvVel < 0 && ++moveDelay == -xInvVel) {
        --xPos;
        moveDelay = 0;
      }
    }
    
  }
  
  PImage spritesheet;
  color transparent;
  
  int scene;
  int sceneAge;
  Vector<Sprite> sprites;
  
  static final int tick = 80;
  static final int resetInterval = 2*tick;
  int lastRun;
  
  PacMan(HeronLX lx)   {
    super(lx);
    spritesheet = loadImage("pacman.png");
    spritesheet.loadPixels();
    transparent = spritesheet.get(0, 0);
    scene = 0;
    sceneAge = 0;
    sprites = new Vector<Sprite>();
    lastRun = millis();
  }
  
  void nextScene() {
    ++scene;
    sceneAge = -1;
    //not 0 because it gets incremented immediately.
    //"last" frame of current scene
  }
  
  public void run(int deltaMs) {
    //frame timing
    int time = millis();
    if (lastRun + resetInterval < time) {
      lastRun = time;
    } else if (time < lastRun + tick) {
      return;
    } else {
      lastRun += tick;
    }
    //flush background first
    setColors(0);
    //scene logic
    switch (scene) {
      case 0:
        if (sceneAge == 0) {
          sprites.clear();
          Sprite pacman = new Sprite(new int[][] {{47, 7}, {7, 27}, {27, 27}, {7, 27}}, 13, 13, -15, 6);
          pacman.setXInvVel(1);
          sprites.add(pacman);
          for (int i = 0; i < 4; ++i) {
            Sprite ghost = new Sprite(new int[][] {{127, 87+20*i}, {147, 87+20*i}}, 14, 14, -55-15*i, 6);
            ghost.setXInvVel(1);
            ghost.setAnimInvVel(2);
            sprites.add(ghost);
          }
          for (int x = 7; x < lx.width - 17; x += 9) {
            sprites.add(new Sprite(new int[][] {{9, 189}}, 2, 2, x, 12));
          }
          Sprite superPill = new Sprite(new int[][] {{6, 186}, {300, 186}}, 8, 8, lx.width - 15, 9);
          superPill.setAnimInvVel(3);
          sprites.add(superPill);
        }
        //chomp pills
        if (sprites.size() > 6 && sprites.get(5).getX() < sprites.get(0).getX() + 6) {  //TODO change after adding ghosts
          sprites.remove(5);
        }
        if (sprites.get(0).getX() > lx.width - 20) {
          nextScene();
        }
        break;
      case 1:
        if (sceneAge == 0) {
          sprites.clear();
          sprites.add(null);
          Sprite pacman = new Sprite(new int[][] {{47, 7}, {7, 7}, {27, 7}, {7, 7}}, 13, 13, lx.width - 20, 6);
          pacman.setXInvVel(-1);
          sprites.add(pacman);
          for (int i = 0; i < 4; ++i) {
            Sprite blinky = new Sprite(new int[][] {{7, 167}, {27, 167}}, 14, 14, 132-15*i, 6);
            blinky.setXInvVel(-3);
            blinky.setAnimInvVel(2);
            sprites.add(blinky);
          }
        }
        int s = sprites.size();
        if (s > 2) {
          int x = sprites.get(2).getX();
          if (x + 4 > sprites.get(1).getX()) {
            sprites.remove(2);
            //sprites.remove(s - 2);
            sprites.setElementAt(new Sprite(new int[][] {{6+(6-s)*20, 230}}, 16, 7, x + 1, 4), 0);
          }
        }
        if (sceneAge >= 142) {
          if (s > 1) {
            sprites.remove(0);
          } else if (sprites.get(0).getX() <= -13) {
            nextScene();
          }
        }
        break;
      case 2:
      case 5:
      case 8:
      case 11:
        if (sceneAge == 0) {
          sprites.clear();
          int ghostNum = (scene - 2) / 3;
          Sprite ghost = new Sprite(new int[][] {{127, 87 + 20*ghostNum}, {147, 87 + 20*ghostNum}}, 14, 14, -14, 6);
          ghost.setXInvVel(1);
          ghost.setAnimInvVel(2);
          sprites.add(ghost);
        }
        if (sprites.get(0).getX() >= 116) {
          nextScene();
        }
        break;
      case 3:
      case 6:
      case 9:
      case 12:
        if (sceneAge == 0) {
          sprites.get(0).setXInvVel(0);
          int ghostNum = (scene - 3) / 3;
          sprites.add(new Sprite(new int[][] {{242, 168+9*ghostNum}}, 67, 7, 40, 9));
        } else if (sceneAge == 40) {
          nextScene();
        }
        break;
      case 4:
      case 7:
      case 10:
      case 13:
        if (sceneAge == 0) {
          sprites.remove(1);
          sprites.get(0).setXInvVel(1);
        }
        if (sprites.get(0).getX() >= lx.width) {
          nextScene();
        }
        break;
      default:
        scene = -1;
        nextScene();
    }
    //draw
    for (int i = sprites.size() - 1; i >= 0; --i) {
      if (sprites.get(i) != null)
        sprites.get(i).run();
    }
    ++sceneAge;
  }
  
}

