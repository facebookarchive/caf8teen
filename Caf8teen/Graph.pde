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

class Graph extends LXPattern {

  final Node[] nodes = new Node[20];
  
  public Graph(HeronLX lx) {
    super(lx);
    for (int i = 0; i < nodes.length; ++i) {
      nodes[i] = new Node(i);
    }
  }

  class Node {
    
    float x, y, r, xVel, yVel;
    QuadraticEnvelope sz;
    QuadraticEnvelope cLength;
    int semaphore = 0;
    
    int state;
    
    final int GROWING = 1;
    final int CONNECTING = 2;
    final int SENDING = 3;
    final int DISCONNECTING = 4;
    final int SHRINKING = 5;
    
    final int index;
    Node target;
    
    Node(int idx) {
      index = idx;
      addModulator(sz = new QuadraticEnvelope(0, 1, 0));
      addModulator(cLength = new QuadraticEnvelope(0, 1, 5000).setEase(QuadraticEnvelope.Ease.BOTH));
      grow();
    }
    
    boolean available() {
      return
        (state == CONNECTING) ||
        (state == SENDING);      
    }
    
    void grow() {
      state = GROWING;
      xVel = random(-3, 3);
      yVel = random(-3, 3);
      x = random(0, lx.width);
      y = random(0, lx.height);
      r = random(3, 8);
      sz.setRange(0, 1, random(1000, 2000)).trigger();
    }
    
    void connect() {
      state = CONNECTING;
      target = null;
    }
    
    void send() {
      state = SENDING;
      cLength.setRange(0, 1, dist(x, y, target.x, target.y) * random(60, 150)).trigger();
    }
        
    void disconnect() {
      state = DISCONNECTING;
      --target.semaphore;
      target = null;
    }
    
    void shrink() {
      state = SHRINKING;
      sz.setRange(1, 0, random(1000, 2000)).trigger();
    }
    
    void drawNode() {
      for (int xv = floor(x - r); xv < ceil(x + r); ++xv) {
        for (int yv = floor(y - r); yv < ceil(y + r); ++yv) {
          if (xv >= 0 && xv < lx.width && yv >= 0 && yv < lx.height) {
            float d = dist(x, y, xv, yv);
            addColor(xv, yv, color(
              (lx.getBaseHuef() + x*.5 + y + d*5) % 360,
              100,
              constrain(sz.getValuef() * 200 - d*(200 / r), 0, 100)
            ));
          }
        }
      }

    }

    void drawConnection() {
      float xp = lerp(x, target.x, cLength.getValuef());
      float yp = lerp(y, target.y, cLength.getValuef());
      for (int xv = floor(xp - 3); xv < ceil(xp + 3); ++xv) {
        for (int yv = floor(yp - 3); yv < ceil(yp + 3); ++yv) {
          if (xv >= 0 && xv < lx.width && yv >= 0 && yv < lx.height) {
            float maxB = constrain(1000 - abs(cLength.getValuef() - 0.5) * 2000, 0, 100);
            addColor(xv, yv, color(
              0,
              0,
              constrain(maxB - dist(xv, yv, xp, yp) * (30 + 50 * abs(cLength.getValuef() - 0.5)), 0, 100)
            ));
          }
        }
      }   
    }      
    
    public void run(int deltaMs) {
      x += xVel * deltaMs / 1000.;
      y += yVel * deltaMs / 1000.;
      drawNode();
      if (state == SENDING) {
        drawConnection();
      }
    }
        
    public void transition() {
      switch (state) {
      case GROWING:
        if (!sz.isRunning()) {
          connect();
        }
        break;
      case CONNECTING:
        Node candidate = nodes[(index + int(random(1, nodes.length))) % nodes.length];
        if (candidate.available()) {
          target = candidate;
          ++target.semaphore;
          send();
        }
        break;
      case SENDING:
        if (!cLength.isRunning()) {
          disconnect();
        }
        break;
      case DISCONNECTING:
        if (semaphore == 0) {
          shrink();
        }
        break;
      case SHRINKING:
        if (!sz.isRunning()) {
          grow();
        }
        break;
      }
    }
  }
  
  public void run(int deltaMs) {
    setColors(0);
    for (Node n : nodes) {
      n.run(deltaMs);
    }
    for (Node n : nodes) {
      n.transition();
    }
  }
}

