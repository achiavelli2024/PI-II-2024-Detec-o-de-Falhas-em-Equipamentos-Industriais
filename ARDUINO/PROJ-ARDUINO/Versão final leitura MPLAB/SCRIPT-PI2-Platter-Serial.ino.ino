#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>

// Instancia o sensor ADXL345
Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);

void setup() {
  Serial.begin(115200);
  
  // Inicializa o sensor
  if(!accel.begin()) {
    Serial.println("Não foi possível encontrar o ADXL345. Verifique as conexões!");
    while(1);
  }
  
  // Configuração adicional opcional
  accel.setRange(ADXL345_RANGE_16_G);  // Ajuste o alcance conforme necessário (2G, 4G, 8G, 16G)
  
  Serial.println("ADXL345 inicializado com sucesso.");
}

void loop() {
  sensors_event_t event; 
  accel.getEvent(&event);

  // Envia os dados para o Serial Plotter
  Serial.print("X: "); Serial.print(event.acceleration.x); 
  Serial.print(" \tY: "); Serial.print(event.acceleration.y); 
  Serial.print(" \tZ: "); Serial.println(event.acceleration.z);
  
  delay(10);  // Ajuste conforme necessário
}

