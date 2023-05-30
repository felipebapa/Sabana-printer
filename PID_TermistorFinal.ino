#include <PIDController.hpp>  // Incluye la biblioteca PIDController.hpp

const int PIN_OUTPUT = 6;  // Define el número del pin de salida

PID::PIDParameters<double> parameters(0.48577, 0.01753, 0);  // Parámetros del controlador PID

PID::PIDController<double> pidController(parameters);  // Crea una instancia del controlador PID

int Vo;  // Variable para almacenar el valor leído del pin analógico A0

float R1 = 100000;  // Resistencia fija del divisor de tensión
float logR2, R2, TEMPERATURA;
float c1 = 0.3555874631e-03, c2 = 2.649451274e-04, c3 = -0.3398704380e-07;  // Coeficientes para la ecuación S-H

void setup() {
  pidController.Setpoint = 150;  // Establece el valor de consigna del controlador PID
  pidController.TurnOn();  // Enciende el controlador PID
  Serial.begin(9600);  // Inicializa la comunicación serie a 9600 bps
}

void loop() {
  Vo = analogRead(A0);  // Lee el valor analógico del pin A0
  R2 = R1 * (1023.0 / (float)Vo - 1.0);  // Convierte la tensión a resistencia
  logR2 = log(R2);  // Calcula el logaritmo de R2
  TEMPERATURA = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2));  // Aplica la ecuación S-H para obtener la temperatura
  TEMPERATURA = TEMPERATURA - 273.15;  // Convierte la temperatura de Kelvin a Celsius
  TEMPERATURA = (TEMPERATURA + 9*TEMPERATURA)/10;  // Suaviza la lectura de la temperatura
  
  pidController.Input = TEMPERATURA;  // Establece el valor de entrada del controlador PID
  pidController.Update();  // Actualiza el controlador PID
  
  analogWrite(PIN_OUTPUT, pidController.Output);  // Escribe la salida del controlador PID en el pin de salida
  
  Serial.print("Temperatura: ");  // Imprime el valor de la temperatura en el monitor serie
  Serial.print(TEMPERATURA);
  Serial.println(" C"); 

  delay(300);  // Demora de medio segundo entre lecturas
  Serial.println(pidController.Output);  // Imprime la salida del controlador PID en el monitor serie
}
