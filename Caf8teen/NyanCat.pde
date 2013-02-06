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

import java.util.LinkedList;

/**
 * Nyan cat!  With flashing lights!
 * Written by Kieren Davies and Dmirty Panin
 */
class NyanCat extends LXPattern {
  
  class Cat {
    
    int xPos;
    int yPos;
    int frame;
    PImage[] frames;
    static final int rbOffset = 8;
    
    public Cat() {
      frames = new PImage[12];
      for (int i = 0; i < 12; ++i) {
        frames[i] = loadImage(String.format("nyancat/cat%02d.png", i));
        frames[i].loadPixels();
      }
      frame = 0;
      xPos = -frames[0].width;
      yPos = 2;
    }
    
    public boolean isDown() {
      return (frame % 6 >= 3);
    }
    
    public void run() {
      PImage img = frames[frame];
      for (int x = 0; x < img.width; ++x) {
        if (x + xPos < 0 || x + xPos >= lx.width) continue;
        for (int y = 0; y < img.height; ++y) {
          color c = img.get(x, y);
          if (c != img.get(0, 0)) {  //top left corner is transparent
            setColor(x + xPos, y + yPos, c);
          }
        }
      }
      if (0 <= xPos + rbOffset && xPos + rbOffset < lx.width) {
        rb.add(xPos + rbOffset, (isDown() ? 4 : 3));
      }
      ++xPos;
      if (xPos > lx.width) xPos = -img.width;
      //move 2 units for every frame advance
      if (xPos % 2 == 0) {
        ++frame;
        frame %= 12;
      }
    }
    
  }
  
  class Rainbow {
    
    class Slice {
      
      int xPos;
      int yPos;
      int age;
      
      public Slice(int x, int y) {
        xPos = x;
        yPos = y;
        age = 0;
      }
      
      public void run() {
        for (int y = 0; y < img.height; ++y) {
          color c = img.get(0, y);
          if (age > thresAge) {
            c = lerpColor(c, bg, map(age, thresAge, maxAge, 0.0, 1.0));
          }
          setColor(xPos, yPos + y, c);
        }
        ++age;
      }
      
      public boolean isDead() {
        return age >= maxAge;
      }
      
    }
    
    PImage img;
    LinkedList<Slice> slices;
    static final int maxAge = 50;
    static final int thresAge = 15;
    
    public Rainbow() {
      img = loadImage("nyancat/rainbow.png");
      img.loadPixels();
      slices = new LinkedList<Slice>();
    }
    
    public void add(int x, int y) {
      slices.addLast(new Slice(x, y));
    }
    
    public void run() {
      colorMode(RGB);  //for proper fading
      for (Slice slice : slices) {
        slice.run();
      }
      colorMode(HSB);  //to not interfere with anything else
      while (!slices.isEmpty() && slices.getFirst().isDead()) {
        slices.removeFirst();
      }
    }
    
  }
  
  class Stars {
    
    class Star {
      
      int xPos;
      int yPos;
      int age;
      
      public Star(int x, int y) {
        xPos = x;
        yPos = y;
        age = 0;
      }
      
      public void run() {
        PImage img = frames[age/2];
        for (int x = 0; x < img.width; ++x) {
          for (int y = 0; y < img.height; ++y) {
            color c = img.get(x, y);
            if (c != img.get(0, 0)) {  //top left corner is transparent
              setColor(x + xPos, y + yPos, c);
            }
          }
        }
        ++age;
      }
      
      public boolean isDead() {
        return age >= 12;
      }
      
    }
    
    PImage[] frames;
    LinkedList<Star> stars;
    
    public Stars() {
      frames = new PImage[6];
      for (int i = 0; i < 6; ++i) {
        frames[i] = loadImage(String.format("nyancat/star%d.png", i));
        frames[i].loadPixels();
      }
      stars = new LinkedList<Star>();
    }
    
    public void run() {
      //add one new star per tick
      stars.addLast(new Star((int) random(lx.width - 7), (int) random(lx.height - 7)));
      //render all current stars
      for (Star star : stars) {
        star.run();
      }
      //clean up dead stars
      while (!stars.isEmpty() && stars.getFirst().isDead()) {
        stars.removeFirst();
      }
    }
    
  }
  
  Cat cat;
  Rainbow rb;
  Stars stars;
  final color bg;
  static final int tick = 50;
  static final int resetInterval = 100;
  int lastrun;
  
  NyanCat(HeronLX lx)   {
    super(lx);
    bg = color(210, 100, 40);
    cat = new Cat();
    rb = new Rainbow();
    stars = new Stars();
    lastrun = millis();
  }
  
  public void run(int deltaMs) {
    //frame timing
    int time = millis();
    if (lastrun + resetInterval < time) {
      lastrun = time;
    } else if (time < lastrun + tick) {
      return;
    } else {
      lastrun += tick;
    }
    //flush background first
    for (int x = 0; x < lx.width; ++x) {
      for (int y = 0; y < lx.height; ++y) {
        setColor(x, y, bg);
      }
    }
    //draw
    rb.run();
    stars.run();
    cat.run();
  }
  
}

