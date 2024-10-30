#include <SPI.h>

// Definições dos pinos e constantes
#define CS 52
#define SDA 74
#define SDO 75
#define SCL 76
#define NUM_SAMPLES 1024  // Número de amostras para FFT

int16_t accelX, accelY, accelZ;
float offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0;
float scaleFactor = 0.0039;  // Exemplo de valor para a escala

// Inicialização do acelerômetro
void initADXL345() {
    pinMode(CS, OUTPUT);
    digitalWrite(CS, HIGH);
    
    SPI.begin();
    SPI.setClockDivider(SPI_CLOCK_DIV16);
    SPI.setDataMode(SPI_MODE3);
    
    // Configurações do ADXL345
    digitalWrite(CS, LOW);
    SPI.transfer(0x2D);  // Power Control Register
    SPI.transfer(0x08);  // Measurement Mode
    digitalWrite(CS, HIGH);
}

// Função para ler os dados do acelerômetro
void readADXL345(int16_t *x, int16_t *y, int16_t *z) {
    digitalWrite(CS, LOW);
    SPI.transfer(0x32 | 0x80 | 0x40); // Iniciar leitura
    
    *x = SPI.transfer(0x00) | (SPI.transfer(0x00) << 8);
    *y = SPI.transfer(0x00) | (SPI.transfer(0x00) << 8);
    *z = SPI.transfer(0x00) | (SPI.transfer(0x00) << 8);
    
    digitalWrite(CS, HIGH);
}

// Função para enviar dados ao Monitor Serial
void sendDataToSerial(int16_t x, int16_t y, int16_t z) {
    // Envia os dados para o Monitor Serial no formato adequado
    Serial.print("Aceleração X: ");
    Serial.print(x);
    Serial.print(" | Aceleração Y: ");
    Serial.print(y);
    Serial.print(" | Aceleração Z: ");
    Serial.println(z);
}

void setup() {
    Serial.begin(115200);  // Inicia a comunicação serial
    initADXL345();  // Inicializa o acelerômetro
}

void loop() {
    for (int i = 0; i < NUM_SAMPLES; i++) {
        readADXL345(&accelX, &accelY, &accelZ);  // Lê os dados do acelerômetro

        // Envia os dados diretamente ao Monitor Serial
        sendDataToSerial(accelX, accelY, accelZ);
        
        // Atraso para controlar a taxa de amostragem
        delay(10);  // Ajuste conforme necessário
    }
}

