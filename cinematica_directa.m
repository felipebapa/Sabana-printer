function [x,y,z,T06] = cinematica_directa(q1,q2,q3,q4,q5,q6)

% Necesitamos los parametros de D-H 

% robot length values (metres)
a = [0, 0, -0.42500, -0.39225, 0, 0]';
d = [0.089419, 0, 0, 0.10915, 0.09465, 0.0823]';
alpha = [0, pi/2, 0, 0, pi/2, -pi/2]';


% De 0 a 1

T01 = [cos(q1) -sin(q1) 0 a(1);
      sin(q1)*cos(alpha(1)) cos(q1)*cos(alpha(1)) -sin(alpha(1)) -sin(alpha(1))*d(1);
      sin(q1)*sin(alpha(1)) cos(q1)*sin(alpha(1)) cos(alpha(1)) cos(alpha(1))*d(1);
      0 0 0 1];


% De 1 a 2 

T12 = [cos(q2) -sin(q2) 0 a(2);
      sin(q2)*cos(alpha(2)) cos(q2)*cos(alpha(2)) -sin(alpha(2)) -sin(alpha(2))*d(2);
      sin(q2)*sin(alpha(2)) cos(q2)*sin(alpha(2)) cos(alpha(2)) cos(alpha(2))*d(2);
      0 0 0 1];

% De 2 a 3

T23 = [cos(q3) -sin(q3) 0 a(3);
      sin(q3)*cos(alpha(3)) cos(q3)*cos(alpha(3)) -sin(alpha(3)) -sin(alpha(3))*d(3);
      sin(q3)*sin(alpha(3)) cos(q3)*sin(alpha(3)) cos(alpha(3)) cos(alpha(3))*d(3);
      0 0 0 1];

% de 3 a 4

T34 = [cos(q4) -sin(q4) 0 a(4);
      sin(q4)*cos(alpha(4)) cos(q4)*cos(alpha(4)) -sin(alpha(4)) -sin(alpha(4))*d(4);
      sin(q4)*sin(alpha(4)) cos(q4)*sin(alpha(4)) cos(alpha(4)) cos(alpha(4))*d(4);
      0 0 0 1];

% de 4 a 5 

T45 = [cos(q5) -sin(q5) 0 a(5);
      sin(q5)*cos(alpha(5)) cos(q5)*cos(alpha(5)) -sin(alpha(5)) -sin(alpha(5))*d(5);
      sin(q5)*sin(alpha(5)) cos(q5)*sin(alpha(5)) cos(alpha(5)) cos(alpha(5))*d(5);
      0 0 0 1];

% de 5 a 6 

T56 = [cos(q6) -sin(q6) 0 a(6);
      sin(q6)*cos(alpha(6)) cos(q6)*cos(alpha(6)) -sin(alpha(6)) -sin(alpha(6))*d(6);
      sin(q6)*sin(alpha(6)) cos(q6)*sin(alpha(6)) cos(alpha(6)) cos(alpha(6))*d(6);
      0 0 0 1];


% Cinematica directa. 
T06 = T01*T12*T23*T34*T45*T56;




% Extrayendo Varaibles

x = T06(1,4);
y = T06(2,4);
z = T06(3,4);

end 