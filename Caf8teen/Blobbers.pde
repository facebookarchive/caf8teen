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

class Blobbers extends LXPattern {

  final Blobber[] blobbers = new Blobber[80];
  final SinLFO hCenter;
  
  Blobbers(HeronLX lx) {
    super(lx);
    for (int i = 0; i < blobbers.length; ++i) {
     blobbers[i] = new Blobber();
    }
    addModulator(hCenter = new SinLFO(lx.width*.25, lx.width*.75, 19000)).trigger();
  }
  
  class Blobber {
    
    float x, y, xv, yv, xa, ya, r, rv;
    
    Blobber() {
      trigger();
    }
    
    final float maxV = 11;
    final float minV = 3;
    final float absV = 8;
    final float absA = 3;
    
    void trigger() {
      float r = random(0, 4);
      if (r < 1) {
        x = -2;
        y = random(0, lx.height);
        xv = random(minV, maxV);
        yv = random(-minV, minV);
      } else if (r < 2) {
        x = lx.width + 2;
        y = random(0, lx.height);
        xv = -random(minV, maxV);
        yv = random(-minV, minV);
      } else if (r < 3) {
        y = -2;
        x = random(0, lx.width);
        xv = random(-absV, absV);
        yv = random(minV, maxV);
      } else {
        y = lx.height + 2;
        x = random(0, lx.width);
        xv = random(-absV, absV);
        yv = -random(minV, maxV);
      }
      xa = random(-absA, absA);
      ya = random(-absA, absA);
      r = random(20, 50);
      rv = random(-2, 2); 
    }
    
    public void run(int deltaMs) {
      x += xv*deltaMs/1000.;
      y += yv*deltaMs/1000.;
      xv += xa*deltaMs/1000.;
      yv += ya*deltaMs/1000.;
      r = constrain(r + rv*deltaMs/1000., 20, 50);
       
      if ((xv > 0 && x > lx.width+2) ||
          (xv < 0 && x < -3) ||
          (yv > 0 && y > lx.height+2) ||
          (yv < 0 && y < -3)) {
         trigger();
      }
      
      float thresh = 100 / r + 1;
      for (int xp = floor(x - thresh); xp < x + thresh; ++xp) {
        for (int yp = floor(y - thresh); yp < y + thresh; ++yp) {
          if (xp >= 0 && xp < lx.width && yp >= 0 && yp < lx.height) {
            addColor(xp, yp, color(
              (lx.getBaseHuef() + abs(xp - hCenter.getValuef())*.4 + yp) % 360,
              100,
              constrain(100 - r*dist(xp, yp, x, y), 0, 100)
            ));
          }
        }
      }
    }
  }
  
  public void run(int deltaMs) {
    setColors(0);
    for (Blobber b : blobbers) {
      b.run(deltaMs);
    }
  }
}
