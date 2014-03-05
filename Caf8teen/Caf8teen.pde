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
import java.net.SocketException;

final int numInnerColumns = 111;
final color fbBlue = #3b5998;
final int dishNicheHeight = 5;
final int dishNicheOffset = 17;
final int dishNicheWidth = 18;

int nodeWidth = 190;
int nodeHeight = 24;
int simulationScale = 6;
int simulationGap = 40;

HeronLX lx;
Kinet kinet;
boolean kinetActive = false;

void setup() {
  size(nodeWidth*simulationScale + simulationGap, nodeHeight*simulationScale);
  lx = new HeronLX(this, nodeWidth, nodeHeight);
  lx.setPatterns(new LXPattern[] {
    new BaseHuePattern(lx),
  });
  lx.tempo.setBpm(60);
  
  final String[] psus = {
    "10.3.201.178",
    "10.3.201.162",
    "10.3.201.189",
    "10.3.201.160",
    "10.3.201.156",
    "10.3.201.184",
  };
  final int portsPerPsu = 16;
  final int portDataBytes = 48*3;
  final KinetPort[] ports = new KinetPort[psus.length*portsPerPsu];
  for (int i = 0; i < psus.length; ++i) {
    for (int j = 0; j < portsPerPsu; ++j) {
      ports[i*portsPerPsu + j] = new KinetPort(psus[i], j+1);
    }
  }
  KinetNode[] nodes = new KinetNode[lx.total];
  for (int i = 0; i < nodes.length; ++i) {
    nodes[i] = null;
    int row = lx.row(i);
    int col = lx.column(i);
    if (col < dishNicheOffset) {
      // Inner Tube left section
      int portIndex = col/2;
      int nodeIndex = (col % 2 == 0) ? (lx.height - 1 - row) : (lx.height + row);
      nodes[i] = new KinetNode(ports[portIndex], nodeIndex);
    } else if (col < dishNicheOffset + dishNicheWidth) {
      // Dish Niche
      if (row < dishNicheHeight) {
        int portIndex = (col < 26) ? 9 : 10;
        int colIndex = (col < 26) ? (col-17) : (col-26);
        int nodeIndex = colIndex * 5 + ((colIndex % 2 == 0) ? (4 - row) : row);
        nodes[i] = new KinetNode(ports[portIndex], nodeIndex);
      } else {
        // There are no physical nodes in the dish niche
        nodes[i] = null;
      }
    } else if (col < numInnerColumns) {
      // Inner Tube right section
      int portIndex = 11 + (col - 35) / 2;
      int nodeIndex = (col % 2 == 1) ? (lx.height - 1 - row) : (lx.height + row);
      switch (col) {
        case 45:
        case 57:
        case 79:
        case 101:
          nodeIndex = row;
          break;
        case 46:
        case 58:
        case 80:
        case 102:
          nodeIndex = 2*lx.height-1-row;
          break;
      }      
      nodes[i] = new KinetNode(ports[portIndex], nodeIndex);
    } else {
      // Outer tube
      int portIndex = 49 + (col - numInnerColumns) / 2;
      int nodeIndex = (col % 2 == 1) ? (lx.height - 1 - row) : (lx.height + row);
      switch (col) {
        case 133:
        case 155:
        case 177:
          nodeIndex = row;
          break;
        case 134:
        case 156:
        case 178:
          nodeIndex = 2*lx.height-1-row;
          break;        
      }
      nodes[i] = new KinetNode(ports[portIndex], nodeIndex);
    }
  }
  try {
    kinet = new Kinet(nodes);
  } catch (SocketException sx) {
    throw new RuntimeException(sx);
  }
   
  LXTransition dissolve = new DissolveTransition(lx).setDuration(10000);
  LXTransition rain = (new WipeTransition(lx, WipeTransition.Direction.DOWN).setDuration(5000));
  
  final int O_CLOCK = 60;
  final int SECONDS = 1000;
  final int MINUTES = 60*SECONDS;
  
  
  lx.setPatterns(new LXPattern[] {
    new LifePattern(lx).setTransition(dissolve),
    new RainingLogo(lx).setTransition(rain),
    new SinWaves(lx).setTransition(dissolve),
    new Graph(lx).setTransition(dissolve),
    new WaitInLine(lx).setTransition(dissolve),
    new FadingBoxes(lx).setTransition(dissolve),
    new Blobbers(lx).setTransition(dissolve),
    new EnterTheDoors(lx).setTransition(dissolve),
    new EveningStars(lx).runDuringInterval(22*O_CLOCK, 5*O_CLOCK).setTransition(dissolve),
    new MorningSunrise(lx).runDuringInterval(5*O_CLOCK, 7*O_CLOCK).setTransition(rain),
    new NyanCat(lx).setTransition(dissolve),
    new PacMan(lx).setTransition(dissolve),
  });
  lx.cycleBaseHue(90*SECONDS);
  lx.enableAutoTransition(5*SECONDS);
  lx.enableSimulation(false);

  setKinet();
  background(0);
  noStroke();
  stroke(#202020);
  fill(#191919);
  rect(numInnerColumns*simulationScale, 0, simulationGap, height);
  rect(dishNicheOffset*simulationScale, dishNicheHeight*simulationScale, dishNicheWidth*simulationScale, height);
  
  println("Caf8teen initialized, press 'k' to toggle live lighting output (currently " + (kinetActive ? "enabled" : "disabled") + ")");
}

void draw() {
  int nodeSize = simulationScale / 3;
  noStroke();
  color[] colors = lx.getColors();
  for (int x = 0; x < lx.width; ++x) {
    for (int y = 0; y < lx.height; ++y) {
      if ((y < dishNicheHeight) || (x < dishNicheOffset) || (x >= dishNicheOffset + dishNicheWidth)) {
        fill(colors[x+y*lx.width]);
        rect(nodeSize + x*simulationScale + (x < numInnerColumns ? 0 : simulationGap), nodeSize + y*simulationScale, nodeSize, nodeSize);
      }
    }
  }
}

void setKinet() {
  if (kinetActive) {
    lx.setKinet(kinet);
  } else {
    lx.setKinet(null);
  }
}

void keyPressed() {
  switch (key) {
    case 'k':
      kinetActive = !kinetActive;
      setKinet();
      println("Kinet live output " + (kinetActive ? "enabled" : "disabled"));
  }
}
