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

import com.heronarts.lx.*;
import com.heronarts.lx.kinet.*;
import com.heronarts.lx.modulator.*;
import com.heronarts.lx.pattern.*;
import com.heronarts.lx.transition.*;
import ddf.minim.*;

final color fbBlue = #3b5998;

void setup() {
  size(1600, 180);
  final HeronLX lx = new HeronLX(this, 95, 2);
  final KinetNode[] nodes = new KinetNode[lx.total];
  
  final KinetPort[] ports = {
    new KinetPort("10.3.225.102", 1), // inner top
    new KinetPort("10.3.217.57", 1), // outer top
    new KinetPort("10.3.225.105", 1), // inner bottom
    new KinetPort("10.3.217.65", 1), // outer bottom
  };
  
  for (int i = 0; i < lx.total; ++i) {
    int row = lx.row(i);
    int col = lx.column(i);
    int kidx;
    int pidx = row*2;
    if (col < 45) {
      kidx = 44 - col;
    } else {
      kidx = 94 - col;
      ++pidx;
    }
    nodes[i] = new KinetNode(ports[pidx], kidx);
  }
  lx.setKinetNodes(nodes);
  lx.oscillateBaseHue((hue(fbBlue) + 300) % 360, (hue(fbBlue) + 60) % 360, 53000);
  lx.enableAutoTransition(180000);

  lx.setPatterns(new LXPattern[] {
    new Shadows(lx).setTransition(new WipeTransition(lx, WipeTransition.Direction.LEFT).setDuration(10000)),
    new BlueWash(lx).setTransition(new WipeTransition(lx, WipeTransition.Direction.LEFT).setDuration(10000)),
    new EvenOdd(lx).setTransition(new WipeTransition(lx, WipeTransition.Direction.LEFT).setDuration(10000)),
    new Scanners(lx).setTransition(new WipeTransition(lx, WipeTransition.Direction.LEFT).setDuration(10000)),
  });
  
}

void draw() {
  // triggers runloop
}
