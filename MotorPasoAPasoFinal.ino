#include <Stepper.h>  // Incluye la biblioteca Stepper, que proporciona funciones para controlar motores paso a paso.

const int stepsPerRevolution = 48;  // Define la cantidad de pasos por revolución del motor paso a paso.
Stepper myStepper(stepsPerRevolution, 8, 9, 10, 11);  // Crea una instancia del objeto Stepper llamado "myStepper" con el número de pasos por revolución y los pines de control del motor.

void setup() {
  myStepper.setSpeed(9);  // Establece la velocidad del motor a 9 RPM.

  Serial.begin(9600);  // Inicializa la comunicación serial con una velocidad de baudios de 9600.
}

void loop() {
  // gira una vuelta en una dirección
  myStepper.step(stepsPerRevolution);  // Hace que el motor avance un número de pasos igual a los pasos por revolución definidos anteriormente.
}
