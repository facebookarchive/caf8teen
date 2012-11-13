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


class WaitInLine extends LXPattern {

  final SawLFO offset = new SawLFO(0, 1, 3000);
  final SinLFO slope = new SinLFO(-5, 5, 19000);
  final SawLFO sPos = new SawLFO(0, 1, 9000);
  final SinLFO triSize = new SinLFO(0.5, 2, 13000);
  final SinLFO bIntensity = new SinLFO(20, 50, 19000);
  final SinLFO maskOffset = new SinLFO(-20, 20, 23000); 
  
  public WaitInLine(HeronLX lx) {
    super(lx);
    addModulator(offset).trigger();
    addModulator(sPos).trigger();
    addModulator(slope).trigger();
    addModulator(triSize).trigger();
    addModulator(bIntensity).trigger();
    addModulator(maskOffset).trigger();
    setTransition((new WipeTransition(lx, WipeTransition.Direction.LEFT)).setDuration(5000));
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      float s = 100*(1. - abs(lx.yposf(i) - (0.5 + 0.5*LXUtils.trif(lx.column(i) / 110. + sPos.getValuef()))));
      float b = 50*(triSize.getValuef()+LXUtils.trif((lx.column(i) + (0.5 - lx.yposf(i))*slope.getValuef())/11. + offset.getValuef()));
      b -= bIntensity.getValuef()*abs(lx.yposf(i) - LXUtils.trif((lx.column(i) + maskOffset.getValuef()) / 60.));
      colors[i] = color(
        (lx.getBaseHuef() + lx.row(i) + .9*abs(lx.column(i) - lx.width/2.)) % 360,
        s,
        constrain(b, 0, 100)
      );
    }
  }
}

