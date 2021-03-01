import controlP5.*;
import processing.serial.*;  

Serial serial;
ControlP5 cp5;

int servoCount = 0;
final int servoParameters = 3;

PFont myFont;
PFont myFontButt;
final int displayWidth = 1600;
final int displayHeight = 800;

final int backgroundColor = color(40, 40, 40);
final float marginPercent = 0.035;

final float minSpeed = 0;
final float maxSpeed = 360;
final float defaultSpeed = 100;
final int speedMarksNumber = 18;
final float minAcceleration = 0.01;
final float maxAcceleration = 1;
final float defaultAcceleration = 0.5;
final int accelerationMarksNumber = 10;
final float minAngle = 10;
final float maxAngle = 170;
final float defaultAngle = 90;
final int angleMarksNumber = 32;
final float defaultValue = 180;

final float buttonPanelHeightPercent = 0.08;
final float buttonPanelHeight = displayHeight * buttonPanelHeightPercent;
final float buttonWidthPercent1 = 0.7;
final float buttonWidthPercent2 = 0.8;

final float xMargin = marginPercent * displayWidth;
final float yMargin = marginPercent * displayHeight;
//final float xMargin = 50;
//final float yMargin = 25;

final float screenWidth = displayWidth - 2 * xMargin;
final float screenHeight = displayHeight - 2 * yMargin - buttonPanelHeight;
float wdth;
final float hght = screenHeight / servoParameters;

final float radiusPercent = 0.7;
final float squarePercent = 0.95;
float knobRadius;
float squareWidth;
float squareHeight;

float x;
final float centeringX = (1 - radiusPercent) * x / 2;

final float y = (displayHeight - 2 * yMargin - buttonPanelHeight) / servoParameters / 2;
final float centeringY = (1 - radiusPercent) * y / 2;

float xSpacing;
final float ySpacing = (displayHeight - 2 * yMargin - buttonPanelHeight) / servoParameters;

int myColorBackground = color(0,0,0);

float[] servoX;
float[] servoY;
float[] squareX;
float[] squareY;

int knobValue = 100;

float[] servoSpeed;
float[] servoAcceleration;
float[] servoAngle;

ArrayList<Knob> knobs = new ArrayList<Knob>();
boolean snapped = false;
boolean update = true;

void setServoSpeed(int index, float value)
{
  servoSpeed[index] = value;
  sendServoData(index, 0);
}
float getServoSpeed(int index){
  return servoSpeed[index];
}

void setServoAcceleration(int index, float value)
{
  servoAcceleration[index] = value;
  sendServoData(index, 1);
}
float getServoAcceleration(int index){
  return servoAcceleration[index];
}

void setServoAngle(int index, float value)
{
  servoAngle[index] = value;
  sendServoData(index, 2);
}
float getServoAngle(int index){
  return servoAngle[index];
}

void setup() {
  size(displayWidth,displayHeight);
  init();
  drawUI(servoCount);
}

void drawUI(int servoNumber){
  setParameters(servoNumber);
  setGrid(servoNumber);
  setKnobs(servoNumber);
  setTopPanel();
}

void draw() {
}

void init(){
  myFont = createFont("Arial", 20);
  myFontButt = createFont("Arial", 15);
  background(backgroundColor);
  fill(0,100);
  
  String port = Serial.list()[0];
  serial = new Serial(this, port, 9600);
  cp5 = new ControlP5(this);
}


void setParameters(int servoNumber){
  wdth = screenWidth / servoNumber;
  x = (displayWidth - 2 * xMargin) / servoCount / 2;
  xSpacing = (displayWidth - 2 * xMargin) / servoCount + centeringX;
  
  servoSpeed = new float[servoNumber];
  servoAcceleration = new float[servoNumber];
  servoAngle = new float[servoNumber];
}

void setGrid(int servoNumber){
  servoX = new float[servoNumber];
  servoY = new float[servoParameters];
  squareX = new float[servoNumber];
  squareY = new float[servoParameters];
    
  if (wdth > hght){
    knobRadius = hght * radiusPercent / 2;
  }
  else {
    knobRadius = wdth * radiusPercent / 2;
  }
    
  squareWidth = wdth * squarePercent;
  squareHeight = hght * squarePercent;
    
  for (int i = 0; i < servoNumber; i++){
    float pos = i * wdth + wdth / 2;
    servoX[i] = xMargin + pos - knobRadius;
    squareX[i] = xMargin + pos - squareWidth / 2;
  }
  for (int i = 0; i < servoParameters; i++){
    float pos = i * hght + hght / 2;
    servoY[i] = buttonPanelHeight + 1.25 * yMargin + pos - knobRadius;
    squareY[i] = buttonPanelHeight + 1.25 * yMargin + pos - squareHeight * squarePercent / 2;
  }
}

void setKnobs(int servoNumber){
  for (int i = 0; i < servoNumber; i++){
    for (int j = 0; j < servoParameters; j++){
      float minVal;
      float maxVal;
      float defVal;
      String knobName;
      int tickMarksNumber;
      
      switch (j)
      {
        case 0:
          minVal = minSpeed;
          maxVal = maxSpeed;
          defVal = defaultSpeed;
          knobName = "Speed";
          tickMarksNumber = speedMarksNumber;
          break;
        case 1:
          minVal = minAcceleration;
          maxVal = maxAcceleration;
          defVal = defaultAcceleration;
          knobName = "Acceleration";
          tickMarksNumber = accelerationMarksNumber;
          break;
        case 2:
          minVal = minAngle;
          maxVal = maxAngle;
          defVal = defaultAngle;
          knobName = "Angle";
          tickMarksNumber = angleMarksNumber;
          break;
        default:
          minVal = 0;
          maxVal = 360;
          defVal = defaultValue;
          knobName = "Knob";
          tickMarksNumber = 10;
          break;
      }
      
      Knob knob = cp5.addKnob(knobName + " " + i)
         .setRange(minVal, maxVal)
         .setValue(defVal)
         .setPosition(servoX[i], servoY[j])
         .setRadius(knobRadius)
         .setNumberOfTickMarks(tickMarksNumber)
         .setTickMarkLength(6)
         .setColorForeground(color(255))
         .setColorBackground(color(0, 160, 100))
         .setColorActive(color(255,255,0))
         .setDragDirection(Knob.VERTICAL)
         .setFont(myFont);
      
      knobs.add(knob);
      rect(squareX[i], squareY[j], squareWidth, squareHeight);
    }
  }
}

void setTopPanel(){
  float firstPanelWidth = 353.4 + 2 * 372;
  float space = (372 - 353.4) / 2;
  int buttonCount = 3;
  float divided = firstPanelWidth / buttonCount;
  float buttonWidth = divided * buttonWidthPercent1;
  float buttonHeight = buttonPanelHeight;
  float buttonPosY = yMargin;
  float buttonPosX;
  
  String buttLabel;
  
  for (int i = 0; i < buttonCount; i++){
    buttonPosX = xMargin + space + i * divided + divided / 2 - buttonWidth / 2;
    
    switch(i){
      case 0:
        buttLabel = "Reset";
        break;
      case 1:
        buttLabel = "Shuffle";
        break;
      case 2:
        buttLabel = "Snap";
        break;
      default:
        buttLabel = "Some Text" + i; 
        break;
    }
    cp5.addBang(buttLabel)
     .setId(0)
     .setPosition(buttonPosX, buttonPosY)
     .setSize(Math.round(buttonWidth), Math.round(buttonHeight))
     .setTriggerEvent(Bang.RELEASE)
     .setColorForeground(color(0, 160, 100))
     .setColorActive(color(0,210,120))
     .setLabel(buttLabel)
     .align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER)
     .setFont(myFontButt);
  }
  
  float secondPanelWidth = 353.4;
  float space2 = 372 - 353.4;
  int buttonCount2 = 2;
  float divided2 = secondPanelWidth / buttonCount2;
  float buttonWidth2 = divided2 * buttonWidthPercent2;
  float buttonPosX2;
  
  for (int i = 0; i < buttonCount2; i++){
    buttonPosX2 = xMargin + space + firstPanelWidth + space2 + i * divided2 + divided2/2 - buttonWidth2/2;
    
    switch(i){
      case 0:
        buttLabel = "Remove";
        break;
      case 1:
        buttLabel = "Add";
        break;
      default:
        buttLabel = "Some Text" + (-i); 
        break;
    }
    cp5.addBang(buttLabel)
     .setId(0)
     .setPosition(buttonPosX2, buttonPosY)
     .setSize(Math.round(buttonWidth2), Math.round(buttonHeight))
     .setTriggerEvent(Bang.RELEASE)
     .setColorForeground(color(0, 160, 100))
     .setColorActive(color(0,210,120))
     .setLabel(buttLabel)
     .align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER)
     .setFont(myFontButt);
  }
}

void addServo(){
  background(backgroundColor);
  fill(0,100);
  
  servoCount++;
  
  setParameters(servoCount);
  setGrid(servoCount);
  
  for (int j = 0; j < servoParameters; j++){
      float minVal;
      float maxVal;
      float defVal;
      String knobName;
      int tickMarksNumber;
      
      switch (j)
      {
        case 0:
          minVal = minSpeed;
          maxVal = maxSpeed;
          defVal = defaultSpeed;
          knobName = "Speed";
          tickMarksNumber = speedMarksNumber;
          break;
        case 1:
          minVal = minAcceleration;
          maxVal = maxAcceleration;
          defVal = defaultAcceleration;
          knobName = "Acceleration";
          tickMarksNumber = accelerationMarksNumber;
          break;
        case 2:
          minVal = minAngle;
          maxVal = maxAngle;
          defVal = defaultAngle;
          knobName = "Angle";
          tickMarksNumber = angleMarksNumber;
          break;
        default:
          minVal = 0;
          maxVal = 360;
          defVal = defaultValue;
          knobName = "Knob";
          tickMarksNumber = 10;
          break;
      }
      
      Knob knob = cp5.addKnob(knobName + " " + (servoCount - 1))
         .setRange(minVal, maxVal)
         .setValue(defVal)
         .setNumberOfTickMarks(tickMarksNumber)
         .setTickMarkLength(6)
         .setColorForeground(color(255))
         .setColorBackground(color(0, 160, 100))
         .setColorActive(color(255,255,0))
         .setDragDirection(Knob.VERTICAL)
         .setFont(myFont);
      
      knobs.add(knob);
  }
  
  int knobIndex = 0;
  
  for (int i = 0; i < servoCount; i++){
    for (int j = 0; j < servoParameters; j++){
      Knob knob = knobs.get(knobIndex);
      
      knob.setPosition(servoX[i], servoY[j])
          .setRadius(knobRadius);
      
      rect(squareX[i], squareY[j], squareWidth, squareHeight);
      knobIndex++;
    }
  }
}

void removeServo(){
  if (servoCount <= 0) return;
  
  background(backgroundColor);
  fill(0,100);
  
  servoCount--;
  
  setParameters(servoCount);
  setGrid(servoCount);
  
  for (int i = 0; i < 3; i++){
    int last = knobs.size()-1;
    knobs.get(last).remove();
    knobs.remove(last);
  }
  
  int knobIndex = 0;
  
  for (int i = 0; i < servoCount; i++){
    for (int j = 0; j < servoParameters; j++){
      Knob knob = knobs.get(knobIndex);
      
      knob.setPosition(servoX[i], servoY[j])
          .setRadius(knobRadius);
      
      rect(squareX[i], squareY[j], squareWidth, squareHeight);
      knobIndex++;
    }
  }
}

void keyPressed() {
  switch(key) {
    case('ы'):
    case('s'):
      snap();
      break;
    case('в'):
    case('d'):
      reset();
      break;
      case('к'):
      case('r'):
      shuffleKnobs();
      break;
    case('='):
      addServo();
      break;
    case('-'):
      removeServo();
      break;
  } 
}

void reset(){
  for (Knob knob : knobs){
      int num = knob.getNumberOfTickMarks();
      
      switch(num){
        case 18:
          knob.setValue(defaultSpeed);
          break;
        case 10:
          knob.setValue(defaultAcceleration);
          break;
        case 32:
          knob.setValue(defaultAngle);
          break;
        default:
          knob.setValue(defaultValue);
          break;
      }
    }
}

void shuffleKnobs(){
  for (Knob knob : knobs){
      knob.shuffle();
    }
}

void snap(){
  snapped = !snapped;
  for (Knob knob : knobs){
    knob.snapToTickMarks(snapped);
  }
}

public void Reset(){
  reset();
}

public void Shuffle(){
  shuffleKnobs();
}

public void Snap(){
  snap();
}

public void Remove(){
  removeServo();
}

public void Add(){
  addServo();
}

public void controlEvent(ControlEvent theEvent) { 
  Controller controller = theEvent.getController();
  if (controller.getId() == 0) return;
  
  String name = controller.getName();
  String[] splitted = name.split(" ");
  String parameter = splitted[0];
  int index = Integer.valueOf(splitted[1]);
  float value = controller.getValue();
  
  switch(parameter){
    case "Speed":
      setServoSpeed(index, value);
      break;
    case "Acceleration":
      setServoAcceleration(index, value);
      break;
    case "Angle":
      setServoAngle(index, value);
      break;
    default:
      println("Default");
      break;
  }
}

void sendServoData(int index, int parameter){
  String separator = " ";
  String ln = "\n";
  String servoData;
  String printedData;
  
  switch (parameter){
    case 0:
      servoData = String.valueOf(parameter) + separator + String.valueOf(index) + separator + String.valueOf(roundValue(getServoSpeed(index)));
      printedData = "Servomotor" + separator + String.valueOf(index) + ln + "Speed" + separator + String.valueOf(roundValue(getServoSpeed(index))) + ln;
      break;
    case 1:
      servoData = String.valueOf(parameter) + separator + String.valueOf(index) + separator + String.valueOf(roundValue(getServoAcceleration(index)));
      printedData = "Servomotor" + separator + String.valueOf(index) + ln + "Acceleration" + separator + String.valueOf(roundValue(getServoAcceleration(index))) + ln;
      break;
    case 2:
      servoData = String.valueOf(parameter) + separator + String.valueOf(index) + separator + String.valueOf(roundValue(getServoAngle(index)));
      printedData = "Servomotor" + separator + String.valueOf(index) + ln + "Angle" + separator + String.valueOf(roundValue(getServoAngle(index))) + ln;
      break;
    default:
      servoData = "-1";
      printedData = "-1";
      break;
  }
  
  println("Sent data: " + servoData);
  println(printedData);
  serial.write(servoData);
}

double roundValue(float value){
  double output = (Math.ceil(value*100))/100;
  return output;
}
