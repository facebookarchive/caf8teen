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
 
 class EvenOdd extends LXPattern {
  SinLFO eo = new SinLFO(0, 1, 19000);

  EvenOdd(HeronLX lx) {
    super(lx);
    addModulator(eo).trigger();
    eo.modulateDurationBy(addModulator(new SinLFO(5000, 13000, 21000)).trigger());
  }
  
  public void run(int deltaMs) {
    for (int i = 0; i < lx.total; ++i) {
      colors[i] = color(
        lx.getBaseHuef(),
        100,
        constrain(100 - abs((lx.column(i) + lx.row(i)) % 2 - eo.getValuef()) * 80, 0, 100)
      );
    }
  }
}

