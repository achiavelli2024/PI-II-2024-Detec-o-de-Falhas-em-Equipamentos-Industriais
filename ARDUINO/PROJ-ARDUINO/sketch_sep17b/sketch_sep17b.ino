#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>

Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified();

void setup(void) 
{
    Serial.begin(9600);  
    if(!accel.begin())
    {
        Serial.println("Nenhum sensor detectado!");
        while(1);
    }
}

void loop(void) 
{
    sensors_event_t event; 
    accel.getEvent(&event);

    // Envia os valores de aceleração com separadores claros
    Serial.print(event.acceleration.x, 2); // Limita a 2 casas decimais
    Serial.print("\t");  // Valor X
    Serial.print(event.acceleration.y, 2); // Limita a 2 casas decimais
    Serial.print("\t");  // Valor Y
    Serial.println(event.acceleration.z, 2); // Limita a 2 casas decimais

    delay(500);  // Ajuste conforme necessário
}
