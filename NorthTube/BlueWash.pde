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

class BlueWash extends LXPattern {
  
  SinLFO pos = new SinLFO(0, lx.width-1, 39000);
  SinLFO topbot = new SinLFO(0, 1, 14000);
  SinLFO offset = new SinLFO(0, TWO_PI, 33000);
  SinLFO satWid = new SinLFO(8, 13, 49000);
  
  BlueWash(HeronLX lx) {
    super(lx);
    addModulator(pos).trigger();
    addModulator(topbot).trigger();
    addModulator(offset).trigger();
    addModulator(satWid).trigger();
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      colors[i] = color(
        (lx.getBaseHuef() + lerp(0, 20, abs(lx.column(i) - pos.getValuef()) / lx.width)) % 360,
        constrain(100 - abs(sin((lx.column(i) - pos.getValuef())/satWid.getValuef())) * 70, 0, 100),
        constrain(100 - abs(lx.row(i) - topbot.getValuef()) * 30 - sin(offset.getValuef() * lx.row(i) + (lx.column(i) - pos.getValuef())/20.) * 30, 0, 100)
        );
    }
  }
}

