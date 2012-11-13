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

/**
 * Pixels forming the Facebook logo rain down from above, stacking
 * up to form a full image that then softly fades out.
 */
class RainingLogo extends LXPattern {
  
  class Column {
    int x;
    int position;
    boolean isDone;
    float falloff;
    
    Click initPause = new Click(0);
    Accelerator a = new Accelerator(0, 0, 1);
    
    Column(int xPos) {
      x = xPos;
      addModulator(a);
      addModulator(initPause);
      reset();
    }

    void reset() {
      isDone = false;
      position = lx.height - 1;
      a.setValue(-3).stop();
      initPause.setDuration(random(1, 5000)).trigger();
    }
    
    void trigger() {
      a.setSpeed(random(0, 5), random(8, 20)).setValue(-1).trigger();
      falloff = random(3, 15);
    }
    
    void done() {
      isDone = true;
      a.stop();
      if (++columnsDone == finishThreshold) {
        finish.trigger();
      }
    }
    
    void run(int deltaMs) {
      if (initPause.isRunning()) {
        if (initPause.click()) {
          initPause.stop();
          trigger();
        }
      }
      for (int y = 0; y < lx.height; ++y) {
        int yv = (y > position ? y : position);
        color c = img.get(x, yv);
        c = color(
          (lx.getBaseHuef() + x/3. + yv) % 360,
          constrain(50 + 2 * (saturation(c) - 50), 0, 100),
          brightness(c)
        );        
        if (y > position) {
          setColor(x, y, c);
        } else {
          // color c = img.get(x, position);
          float l;
          if (y > a.getValuef()) {
            l = max(0, 1 - (y-a.getValuef()) / 2.);
          } else if ((y == position) && (a.getValuef() > y)) {
            l = 1;
          } else {
            l = max(0, 1 - (a.getValuef() - y) / falloff);
          }
          setColor(x, y, color(
            hue(c),
            saturation(c),
            brightness(c) * l
          ));
        }
      }
      if (a.isRunning() && (a.getValuef() > position + falloff)) {
        trigger();
        if (--position < 0) {
          done();
        }
      }
    }
  }

  final int finishThreshold = 85;
  Column[] columns;
  PImage img;
  int columnsDone;
  LinearEnvelope finish = new LinearEnvelope(0, 100, 5000);

  RainingLogo(HeronLX lx) {
    super(lx);
    addModulator(finish);
    img = loadImage("RainingLogo.png");
    img.loadPixels();
    columns = new Column[lx.width];
    columnsDone = 0;
    for (int i = 0; i < lx.width; ++i) {
      columns[i] = new Column(i);
    }
  }
  
  public void restart() {
    setColors(0);
    finish.stop().setValue(0);
    columnsDone = 0;
    for (Column c : columns) {
      c.reset();
    }
  }
  
  public void onActive() {
    restart();
  }
  
  public void run(int deltaMs) {
    for (Column c : columns) {
      c.run(deltaMs);
    }
    if (finish.isRunning()) {
      for (int i = 0; i < lx.total; ++i) {
        colors[i] = color(
          hue(colors[i]),
          max(0, saturation(colors[i]) - finish.getValuef()),
          max(0, brightness(colors[i]) - finish.getValuef())
          );
      }
    }
    if (finish.getValuef() >= 100) {
      restart();
    }
  }
}

