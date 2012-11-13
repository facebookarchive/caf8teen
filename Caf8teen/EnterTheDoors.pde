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

class EnterTheDoors extends LXPattern {
  
  private final SawLFO offset = new SawLFO(0, 1, 1000);
  private final SinLFO stripeWidth = new SinLFO(20, 50, 15000);
  private final SinLFO bendAmount = new SinLFO(4, 20, 9000);
  private final TriangleLFO speed = new TriangleLFO(2000, 5000, 21000); 
  private final SinLFO triScale = new SinLFO(100, 140, 19000);
  private final SawLFO triOffset = new SawLFO(0, 1, 6000);
  private final SinLFO insanity = new SinLFO(1.5, 4, 23000);
  
  public EnterTheDoors(HeronLX lx) {
    super(lx);
    addModulator(speed).trigger();
    addModulator(offset.modulateDurationBy(speed)).trigger();
    addModulator(stripeWidth).trigger();
    addModulator(bendAmount).trigger();
    addModulator(triScale).trigger();
    addModulator(triOffset).trigger();
    addModulator(insanity).trigger();
    setTransition(new WipeTransition(lx, WipeTransition.Direction.LEFT).setDuration(5000));
  }
  
  public void run(int deltaMs) {
    for (int x = 0; x < lx.width; ++x) {
      
      float sPos = (1 + LXUtils.trif(x/triScale.getValuef() + triOffset.getValuef())) * lx.height/2.;
      float sPos2 = (1 + LXUtils.trif(x/triScale.getValuef() + 0.5 + triOffset.getValuef())) * lx.height/2.;
      
      for (int y = 0; y < lx.height; ++y) {
        int i = x + y*lx.width;
      
        // Computes the distance from the center opening
        float d = abs(x - numInnerColumns);
    
        // Mutates the distance by the vertical position, to put a bend in
        // the stripes yielding the appearance of chevron-like arrows moving inwards
        d += bendAmount.getValuef() * (0.5 - abs(lx.yposf(i) - 0.5));
        
        // The brightness is a triangle function of the distance, the width of the stripes
        // modulated by a default brightness value
        float b = constrain(stripeWidth.getValuef() + 75*LXUtils.trif(d/8. + offset.getValuef()), 0, 100);
        float s = constrain(20 + 7*abs(y - sPos), 0, 100);
        b = constrain(b - insanity.getValuef()*abs(y - sPos2), 0, 100);
        
        colors[i] = color((lx.getBaseHuef() + d/1.3 + y) % 360, s, b);
      }
    }
  }
}

