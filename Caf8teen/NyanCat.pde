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
class NyanCat extends LXPattern {

  PImage[] nyanframes = new PImage[12];
  
  NyanCat(HeronLX lx)   {
    super(lx);
    nyanframes[0] = loadImage("nyancat00.png");
    nyanframes[0].loadPixels();
    setColors(255);
  }
  
  public void run(int deltaMs) {
    PImage img = nyanframes[0];
    for (int x = 0; x < img.width; ++x) {
      for (int y = 0; y < img.height; ++y) {
        color c = img.get(x, y);
        if (c != 255) {
          setColor(x + 40, y, c);
        }
      }
    }
  }
}

