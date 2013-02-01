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
  int nyanpos;
  int nyanframe;
  
  NyanCat(HeronLX lx)   {
    super(lx);
    for (int frame = 0; frame < 12; ++frame) {
      nyanframes[frame] = loadImage(String.format("nyancat%02d.png", frame));
      nyanframes[frame].loadPixels();
    }
    nyanframe = 0;
    nyanpos = -nyanframes[0].width;
  }
  
  public void run(int deltaMs) {
    setColors(127);
    PImage img = nyanframes[nyanframe];
    for (int x = 0; x < img.width; ++x) {
      if (x + nyanpos < 0 || x + nyanpos >= lx.width) continue;
      for (int y = 0; y < img.height; ++y) {
        color c = img.get(x, y);
        if (c != img.get(0, 0)) {
          setColor(x + nyanpos, y + 2, c);
        }
      }
    }
    ++nyanpos;
    if (nyanpos > lx.width) nyanpos = -img.width;
    if (nyanpos % 3 == 0) {
      ++nyanframe;
      nyanframe %= 12;
    }
    delay(20);
  }
}

