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

class FadingBoxes extends LXPattern {

  final OneBox[] boxes = new OneBox[80];
  final SinLFO hCenter;
  final SinLFO sWash;
  final SinLFO sSlope;

  FadingBoxes(HeronLX lx) {
    super(lx);
    addModulator(hCenter = new SinLFO(lx.width*.25, lx.width*.75, 19000)).trigger();
    addModulator(sWash = new SinLFO(-10, lx.width+10, 25000)).trigger();
    addModulator(sSlope = new SinLFO(-3, 3, 9000)).trigger();
    for (int i = 0; i < boxes.length; ++i) {
      boxes[i] = new OneBox();
    }
  }
  
  public void run(int deltaMs) {
    setColors(0);
    for (OneBox b : boxes) {
      b.run(deltaMs);
    }
  }
  
  class OneBox {
    
    int x, y, w, h;
    
    Accelerator a;
    
    OneBox() {
      addModulator(a = new Accelerator(0, random(20, 50), -random(8, 14))).trigger();
      trigger();
    }
    
    void trigger() {
      w = floor(random(3, 14));
      h = floor(random(3, 14));
      x = floor(random(0, lx.width - 1 - w));
      y = floor(random(0, lx.height - 1 - h));
      a.trigger();
    }
    
    public void run(int deltaMs) {
      if (a.getValuef() < 0) {
        trigger();
      }
      for (int xp = x; xp < x + w; ++xp) {
        for (int yp = y; yp < y + h; ++yp) {
          addColor(xp, yp, color(
            (lx.getBaseHuef() + abs(xp - hCenter.getValuef())*.5 + + yp + 4*dist(xp, yp, x+(w-1)/2., y + (h-1)/2.)) % 360,
            min(100, 40 + abs(xp + (yp - (lx.height-1)/2.)*sSlope.getValuef() - sWash.getValuef())),
            constrain(a.getValuef(), 0, 100)
          ));
        }
      }
    }
  }
}
