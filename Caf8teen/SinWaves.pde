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

class SinWaves extends LXPattern {
  
  final OneWave[] waves = new OneWave[3];
  
  SinWaves(HeronLX lx) {
    super(lx);
    for (int i = 0; i < waves.length; ++i) {
      waves[i] = new OneWave();
    }
  }
  
  class OneWave {
    final SinLFO waveCenter;
    final SinLFO magnitude;
    final SinLFO period;
    final TriangleLFO falloff;
    final TriangleLFO hVertex;

    final SinLFO modCenter;
    final SinLFO modPeriod;

    OneWave() {
      addModulator(waveCenter = new SinLFO(lx.width/4., 3*lx.width/4., random(40000, 50000))).trigger();
      addModulator(magnitude = new SinLFO(3, lx.height, random(9000, 19000))).trigger();
      addModulator(period = new SinLFO(3, 16, random(49000, 61000))).trigger();
      addModulator(falloff = new TriangleLFO(10, 40, random(15000, 21000))).trigger();
      addModulator(hVertex = new TriangleLFO(-3, 3, random(16000, 21000))).trigger();
      addModulator(modCenter = new SinLFO(0, lx.width, random(35000, 48000))).trigger();
      addModulator(modPeriod = new SinLFO(20, 60, random(25000, 39000))).trigger();
    }

    public void run(int deltaMs) {
      for (int x = 0; x < lx.width; ++x) {
        float m = magnitude.getValuef() * sin((x - modCenter.getValuef()) / modPeriod.getValuef());
        float val = lx.height/2. + sin((x - waveCenter.getValuef()) / period.getValuef()) * m / 2.;
        for (int y = 0; y < lx.height; ++y) {
          float b = constrain(100 - falloff.getValuef()*abs(y - val), 0, 100);
          if (b > 0) {
            addColor(x, y, color(
              (360 + lx.getBaseHuef() + 0.5*abs(x - waveCenter.getValuef()) + (y - lx.height/2.)*hVertex.getValuef()) % 360,
              100,
              b    
            ));
          }
        }
      }
    }
  }
  
  public void run(int deltaMs) {
    setColors(0);
    for (OneWave w : waves) {
      w.run(deltaMs);
    }
  }
  
}
