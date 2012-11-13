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
 
 class Shadows extends LXPattern {
  
  class Shadow {
    SinLFO xPos;

    Shadow() {
      addModulator(xPos = new SinLFO(random(-2, 5), random(lx.width-5, lx.width+1), random(31000, 37000))).trigger();
      xPos.setValue(random(5, lx.width-5));
    }
    
    float distance(int i) {
      return abs(lx.column(i) - xPos.getValuef());
    }
  }
  
  Shadow[] topShadows;
  Shadow[] bottomShadows;
  
  SinLFO topWashout, bottomWashout;
  
  public Shadows(HeronLX lx) {
    super(lx);
    int NUM_SHADOWS = 4;
    topShadows = new Shadow[NUM_SHADOWS];
    bottomShadows = new Shadow[NUM_SHADOWS];
    for (int i = 0; i < NUM_SHADOWS; ++i) {
      topShadows[i] = new Shadow();
      bottomShadows[i] = new Shadow();
    }
    addModulator(topWashout = new SinLFO(0, lx.width-1, random(9000, 15000))).trigger();
    addModulator(bottomWashout = new SinLFO(0, lx.width-1, random(9000, 15000))).trigger();
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      float d = 100;
      Shadow[] shadows = (lx.row(i) == 0) ? topShadows : bottomShadows;
      for (Shadow s : shadows) {
        d = min(d, s.distance(i));
      }
      SinLFO washout = (lx.row(i) == 0) ? topWashout : bottomWashout;
      colors[i] = color(
        (lx.getBaseHuef() + 10*sin(d/8.)) % 360,
        constrain(abs(lx.column(i) - washout.getValuef()) * 4, 0, 100),
        constrain(d*5, 0, 100)
      );
    }
  }
}

