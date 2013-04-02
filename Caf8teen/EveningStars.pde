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

import java.util.Collections;
import java.util.List;

class EveningStars extends LXPattern {

  private class Star {

    int index;
    final Accelerator brt = new Accelerator(0, 200, -10);
    final TriangleLFO sat = new TriangleLFO(20, 100, random(7000, 13000));

    Star() {
      clearColors();
      addModulator(brt);
      addModulator(sat).trigger();
      trigger();
    }

    void trigger() {
      index = starOrder.get(starIndex);
      starIndex = (starIndex + 1) % starOrder.size();
      brt.setSpeed(random(40, 90), random(-20, -100)).trigger();
    }

    public void run(int deltaMs) {
      if (brt.getValuef() < -10) {
        trigger();
      }
      setColor(index, color(
        (lx.getBaseHuef() + lx.row(index)) % 360, 
        sat.getValuef(), 
        constrain(brt.getValuef(), 0, 100)
      ));
    }
  }

  final List<Integer> starOrder;
  int starIndex;
  final Star[] stars;

  public EveningStars(HeronLX lx) {
    super(lx);
    setTransition(new IrisTransition(lx).setDuration(10000));
    
    starOrder = new ArrayList<Integer>(lx.total);
    for (int i = 0; i < lx.total; ++i) {
      starOrder.add(i);
    }
    Collections.shuffle(starOrder);
    starIndex = 0;

    stars = new Star[lx.total / 8];
    for (int i = 0; i < stars.length; ++i) {
      stars[i] = new Star();
    }
  }

  public void run(int deltaMs) {
    for (Star s : stars) {
      s.run(deltaMs);
    }
  }
}

