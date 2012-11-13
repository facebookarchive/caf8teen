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
 
 class Scanners extends LXPattern {
  
  SinLFO[] pos;
  SinLFO[] falloff;
  
  Scanners(HeronLX lx) {
    super(lx);
    pos = new SinLFO[lx.height];
    falloff = new SinLFO[lx.height];
    for (int i = 0; i < lx.height; ++i) {
      addModulator(pos[i] = new SinLFO(0, lx.width-1, 4000+5000*i)).trigger();
      pos[i].modulateDurationBy(addModulator(new SinLFO(13000, 29000, 18000 + i*3000)).trigger());
      addModulator(falloff[i] = new SinLFO(0.6, 2, 19000+5000*i)).trigger();
    }
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      colors[i] = color(
        (lx.getBaseHuef() + lx.column(i) / 4.) % 360,
        constrain(saturation(fbBlue) - abs(lx.column(i) - lx.width/2.), 0, 100),
        constrain(100 - abs(lx.column(i) - pos[lx.row(i)].getValuef())*falloff[lx.row(i)].getValuef(), 0, 100)
      );
    }
  }
}
