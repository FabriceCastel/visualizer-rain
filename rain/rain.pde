import processing.sound.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

// Canvas
float swf = 1.0; // stroke weight factor for larger canvas scaling, use ~1.5 for 1080p
float frame = 0; // float for anim speed stretch

// Audio
int bands = 256;
float[] spectrum = new float[bands];
SoundFile song;
FFT fft;

void setup(){
  size(800, 700); //fullScreen();
  textSize(16);
  
  // audio setup
  fft = new FFT(this, bands);
  
  // setup for a fixed sound file in the data/ directory
  song = new SoundFile(this, "matale.mp3");
  song.play();
  fft.input(song);
  
  // setup for an arbitraty audio source (laptop mic, etc)
  //AudioIn in = new AudioIn(this, 0);
  //in.play();
  //fft.input(in);
}

String statistics = "";

void draw(){
  fft.analyze(spectrum);
  translate(width/2, height/2);
  background(0);
  
  // debug string
  // statistics = "";

  float lowFreq = spectrum[0];
  float highFreq = spectrum[bands - 202] * 51.4;
  drawRain(120, highFreq, lowFreq);
  drawRainMask();
  drawSquareA(120);
  
  // debug text print on canvas
  // writeText();

  // make dem lil' droplets go by faster with the bass
  frame += 1 + lowFreq*0.62*1;
}

// white square outline
void drawSquareA(float duration){
  float animLen = duration/2.0;
  strokeWeight(swf*2.0);
  stroke(255);
  
  float prog = min(frame / animLen, 1.0);
  float len = min(height, width) / 1.5;
  line(-0.5*len, -0.5*len,
    -0.5*len + prog*len, -0.5*len);
  line(0.5*len, 0.5*len,
    0.5*len - prog*len, 0.5*len);
  
  float prog2 = min(frame / animLen - 1.0, 1.0);
  if(prog2 > 0.0){
    line(0.5*len, -0.5*len,
      0.5*len, -0.5*len + prog2*len);
    line(-0.5*len, 0.5*len,
      -0.5*len, 0.5*len - prog2*len);
  }
}

// draw black boxes around the white square to cover rain drop
// fat line weight bleeding out
void drawRainMask(){
  noStroke();
  fill(0);
  float wd = min(height, width) / 1.5;
  rect(-0.5*width, -0.5*height, (width-wd)/2, height);
  rect(-0.5*width, -0.5*height, width, (height-wd)/2);
  rect(0.5*width, 0.5*height, -1*(width-wd)/2, -height);
  rect(0.5*width, 0.5*height, -width, -1*(height-wd)/2);
}

// smoother rain thickness draw on release
float smoothThickness = 0.0;
float smoothGreen = 0.0;

void drawRain(float delay, float lowFreq, float highFreq){
  float thickCap = 17.6;
  smoothThickness = max(lowFreq*10.0, smoothThickness - 0.5);
  if(smoothThickness > thickCap) smoothThickness = thickCap;
  smoothGreen = max(highFreq*323.6, smoothGreen - 8);
  
  // debug stats
  // addStat("st", smoothThickness);
  // addStat("sg", smoothGreen);
  
  if(frame > delay){
    strokeWeight(swf*1.0*max(smoothThickness, 1.0));
    
    float r = 160 + smoothGreen/3;
    float g = 100 + smoothGreen;
    float b = 255;
    
    float wd = min(height, width) / 1.5;
    float rsp = 0.5 * swf; // space between rain lines
    for(float i = 0; i < wd; i += rsp){
      float x = -0.5*wd + i;
      float drops = notReallyRng(x/0.000125125) * 4.0;
      float dropDelta = notReallyRng(x * 5125.2521) * 12561.124;
      float dropLen = 0.15*wd/drops;
      float shakeAmp = 0.003;
      if(drops % 1 > 0.5){
        x += shakeAmp*sin(frame*2.9)*drops*drops*max(smoothGreen - 112, 0);
      } else {
        x += shakeAmp*cos(frame*2.2)*drops*drops*max(smoothGreen - 112, 0);
      }
      x = ((x + wd) % wd) - 0.5*wd;
      for(float d = 2.0; d < drops + 2.0; d++){
        float y1 = ((d*wd/drops + 2.0*(frame - delay)*(4.0/drops) + dropDelta) % (wd+wd/drops)) - 0.5*wd - wd/drops;
        float y2 = min(y1 + dropLen, 0.5*wd);
        
        // experimental velocity changes in & out of the middle
        // fast approx square root hack to make the sketch
        // not run like a potato
        //
        // float sqrtWeight = 0.4;
        // float www = 2.0;
        // float yy1 = (float)Double.longBitsToDouble( ( ( Double.doubleToLongBits( abs(www*y1/wd) )-(1l<<52) )>>1 ) + ( 1l<<61 ) );
        // y1 = (1.0-sqrtWeight)*y1 + sqrtWeight*yy1*(1.0/www)*wd*y1/abs(y1);
        // float yy2 = (float)Double.longBitsToDouble( ( ( Double.doubleToLongBits( abs(www*y2/wd) )-(1l<<52) )>>1 ) + ( 1l<<61 ) );
        // y2 = (1.0-sqrtWeight)*y2 + sqrtWeight*yy2*(1.0/www)*wd*y2/abs(y2);
        
        if(y2 > -0.5*wd){
          // vertical fade
          float vfade = 0.5 * (0.5*wd - abs(y1)) / wd;
          
          // red fluctuations
          float rflux = sin(frame/150 + (x + y1)/330) * 72.2;
          float twinkle = sin(frame/88 + x + y1/26) * 30.0;
          twinkle *= max(0.0, (150 - smoothGreen)/150);
          
          stroke(r+rflux+twinkle, g + 20*drops + twinkle, b + twinkle, (100 + 80 * drops) * (vfade+0.08) * (max(0.0, min((frame - (delay-10))/delay, 1.0))));
          
          y1 = max(y1, -0.5*wd);
          line(x, y1, x, y2);
        }
      }
    }
  }
}

// Range: [0 - 1]
float notReallyRng(float seed){
  return (1.0+(sin(seed/20.0)*cos(seed/34.5)))/2.0;
}



// Everything beyond this point is debugging functionality


void writeText(){
  fill(255);
  float wd = min(height, width) / 2;
  text(statistics, -width/2, -height/2, (width-wd)/2, height);
  
  statFrames++;
}

// add a stat to the statistics string in the order given,
// keep track of peaks for more legible (human) readings
HashMap<String, Float> statsRaw = new HashMap<String, Float>();
HashMap<String, Float> statsPeaks = new HashMap<String, Float>();
HashMap<String, Integer> statsAge = new HashMap<String, Integer>();
int statFrames = 0;

void addStat(String alias, float value){
  //statsRaw.put(alias, value);
  if(statsPeaks.get(alias) != null){
    float pval = statsPeaks.get(alias);
    statsPeaks.put(alias, max(value, 0.7*pval - 0.1));
  } else {
    statsPeaks.put(alias, value);  
  }
  
  if(statFrames % 60 == 0){
    statistics += alias + ": " + Math.round(value) + "\n";
  } else {
    statistics += alias + ": " + Math.round(statsPeaks.get(alias)) + "\n";
  }
}