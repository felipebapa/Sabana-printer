#include <PIDController.hpp>
const int PIN_INPUT = 0;
const int PIN_OUTPUT = 6;
PID::PIDParameters<double> parameters(0.47818, 0.01743, 0);
PID::PIDController<double> pidController(parameters);
int Vo;
float R1 = 100000;              // resistencia fija del divisor de tension 
float logR2, R2, TEMPERATURA;
float c1 = 0.3555874631e-03, c2 = 2.649451274e-04, c3 = -0.3398704380e-07; // coeficientes de S-H
void setup() {
  //pidController.Input = analogRead(PIN_INPUT);
  pidController.Setpoint = 215;
  pidController.TurnOn();
  Serial.begin(9600);		// inicializa comunicacion serie a 9600 bps
}
void loop() {
  
  Vo = analogRead(A0);			// lectura de A0
  R2 = R1 * (1023.0 / (float)Vo - 1.0);	// conversion de tension a resistencia
  logR2 = log(R2);			// logaritmo de R2 necesario para ecuacion
  TEMPERATURA = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2)); 	// ecuacion S-H
  TEMPERATURA = TEMPERATURA - 273.15;   // Kelvin a Centigrados (Celsius)
  TEMPERATURA = (TEMPERATURA + 9*TEMPERATURA)/10;
  pidController.Input = TEMPERATURA;
  pidController.Update();
  analogWrite(PIN_OUTPUT, pidController.Output);
  Serial.print("Temperatura: "); 	// imprime valor en monitor serie
  Serial.print(TEMPERATURA);
  Serial.println(" C"); 
  delay(100);				// demora de medio segundo entre lecturas
  Serial.println(pidController.Output);
}
