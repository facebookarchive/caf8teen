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

/**
 * Nyan cat!
 */

import java.util.LinkedList;

class NyanCat extends LXPattern {
  
  class Cat {
    
    int pos;
    int frame;
    PImage[] frames;
    static final int rboffset = 8;
    
    public Cat() {
      frames = new PImage[12];
      for (int i = 0; i < 12; ++i) {
        frames[i] = loadImage(String.format("nyancat%02d.png", i));
        frames[i].loadPixels();
      }
      frame = 0;
      pos = -frames[0].width;
    }
    
    public int getPos() {
      return pos;
    }
    
    public boolean isDown() {
      return (frame % 6 >= 3);
    }
    
    public void run() {
      PImage img = frames[frame];
      for (int x = 0; x < img.width; ++x) {
        if (x + pos < 0 || x + pos >= lx.width) continue;
        for (int y = 0; y < img.height; ++y) {
          color c = img.get(x, y);
          if (c != img.get(0, 0)) {
            setColor(x + pos, y + 2, c);
          }
        }
      }
      if (0 <= pos + rboffset && pos + rboffset < lx.width) {
        rb.add(pos + rboffset, (isDown() ? 4 : 3));
      }
      ++pos;
      if (pos > lx.width) pos = -img.width;
      if (pos % 2 == 0) {
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
      public void draw() {
        for (int y = 0; y < img.height; ++y) {
          color c = img.get(0, y);
          if (age > thresAge) {
            colorMode(RGB, 255);
            c = color(map(age, maxAge, thresAge, red(bg), red(c)),
                      map(age, maxAge, thresAge, green(bg), green(c)),
                      map(age, maxAge, thresAge, blue(bg), blue(c)));
          }
          setColor(xPos, yPos + y, c);
        }
      }
      public void incrAge() {
        ++age;
      }
      public int getAge() {
        return age;
      }
    }
    
    PImage img;
    LinkedList<Slice> slices;
    static final int maxAge = 50;
    static final int thresAge = 15;
    
    public Rainbow() {
      img = loadImage("nyanrainbow.png");
      img.loadPixels();
      slices = new LinkedList<Slice>();
    }
    
    public void add(int x, int y) {
      slices.addLast(new Slice(x, y));
    }
    
    public void run() {
      for (Slice slice : slices) {
        slice.draw();
        slice.incrAge();
      }
      while (!slices.isEmpty() && slices.getFirst().getAge() >= maxAge) {
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
      public void draw() {
        PImage img = frames[age/2];
        for (int x = 0; x < img.width; ++x) {
          for (int y = 0; y < img.height; ++y) {
            color c = img.get(x, y);
            if (c != img.get(0, 0)) {
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
    
    static final int newstars = 1;
    PImage[] frames;
    LinkedList<Star> stars;
    
    public Stars() {
      frames = new PImage[6];
      for (int i = 0; i < 6; ++i) {
        frames[i] = loadImage(String.format("nyanstar%d.png", i));
        frames[i].loadPixels();
      }
      stars = new LinkedList<Star>();
    }
    
    public void run() {
      for (int i = 0; i < newstars; ++i) {
        stars.addLast(new Star((int) random(lx.width - 7), (int) random(lx.height - 7)));
      }
      for (Star star : stars) {
        star.draw();
      }
      while (!stars.isEmpty() && stars.getFirst().isDead()) {
        stars.removeFirst();
      }
    }
    
  }
  
  Cat cat;
  Rainbow rb;
  Stars stars;
  final color bg;
  static final int interval = 50;
  int lastdraw;
  
  NyanCat(HeronLX lx)   {
    super(lx);
    colorMode(RGB, 255);
    bg = color(0, 0, 80);
    cat = new Cat();
    rb = new Rainbow();
    stars = new Stars();
    lastdraw = 0;
  }
  
  public void run(int deltaMs) {
    int time = millis();
    if (time < lastdraw + interval) return;
    //flush background first
    for (int x = 0; x < lx.width; ++x) {
      for (int y = 0; y < lx.height; ++y) {
        setColor(x, y, bg);
      }
    }
    rb.run();
    stars.run();
    cat.run();
    //setColor((int)random(lx.width), (int)random(lx.height), color(255, 255, 255));
    lastdraw = time;
  }
}

