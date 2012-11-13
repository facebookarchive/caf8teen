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

class MorningSunrise extends LXPattern {
  
  final SinLFO yoffset = new SinLFO(260, 160, 30000);
  final SinLFO xoffset = new SinLFO(-50, 50, 23000);
  
  public MorningSunrise(HeronLX lx) {
    super(lx);
    addModulator(xoffset).trigger();
    addModulator(yoffset).trigger();
    setTransition(new WipeTransition(lx, WipeTransition.Direction.UP).setDuration(10000));
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      float d = dist(lx.column(i), lx.row(i), lx.width/2. + xoffset.getValuef(), lx.height + yoffset.getValuef());
      float h = lx.row(i) - yoffset.getValuef();
      colors[i] = color(
        (380 - d*.04) % 360,
        constrain(-200 + 1.3*d, 30, 100),
        constrain(500 - 1.9*d, 0, 100)
      );
    }
  }
}

