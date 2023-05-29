function [Theta] = analitica(T)

% robot length values (milimeters )

    
% robot length values (metres)
a = [0, 0, -0.42500, -0.39225, 0, 0]';
d = [0.089159, 0, 0, 0.10915, 0.09465, 0.0823]';
alpha = [0, pi/2, 0, 0, pi/2, -pi/2]';

% Evaluacion del indice de destreza. 

% Si el punto esta entre 0 a 350 mm 

Punto = T(1:2,4); % Sacamos los puntos 
Arco = norm(Punto');

    if Arco < 0.35

        % Si tenemos que esta entre 0.350 m, queremos que el efector final este
        % mirando hacia el efector. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 1 

        % Posicion de 5 vista desde el 0 
        P05 = T*[0;0;-d(6); 1];

        % Vamos a aproximar el valor de la posicoion debido a la precision manejada
        % en los parametros de D-H}

        valor = P05(2);
        precision = 4;
        factor = 10^precision;
        resultado = round(valor * factor) / factor;


        % Entonces, vamos a tomar la configuracion del angulo positivo, Para esto,
        % tenemos lo siguiente. 

        if resultado < 0

            % Tenemos la configuracion del 3 y 4 cuadrante. 
            Theta1 = pi - abs(atan2(P05(2),P05(1))) - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))));


        elseif resultado > 0

            % Tenemos la configuracion del 1 y 2 cuadrante. 
            Theta1 = pi + abs(atan2(P05(2),P05(1))) - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))));

        elseif resultado == 0

            if P05(1)<0
                % Si estamos en el cuadrante 2 pero con y = 0 
                Theta1 = (3*pi/2) + (pi/2 - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))))); 
            else
                % Si estamos en x > 0
                Theta1 = (pi) + (pi/2 - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))))); 
            end
        end 

        % Quedo lista
%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 5 

        % Posicion del efector final en relacion con la base 
        P06 = [T(1:3,4)]; 

        % Estamos en cuadrante 3 y 4 

        % Estando en 3
        % Sacamos el origen de 6 visto en 1.
        P16 = abs(((rotz(Theta1))')*(P06));
       
        % Formulacion angulo 5 
        Theta5 = acos((P16(2) - d(4))/(d(6))); % Tener presente que esta funcion limita la accion de Theta 5 de 0 a 90°. 

        % Quedo listo. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Encontrando THETA 6

        % Vamos primero a encontrar una relacion entre en marco 6 y el marco 1. 

        % Tenemos que 
        q1 = Theta1; 

        T01 = [cos(q1) -sin(q1) 0 a(1);
            sin(q1)*cos(alpha(1)) cos(q1)*cos(alpha(1)) -sin(alpha(1)) -sin(alpha(1))*d(1);
            sin(q1)*sin(alpha(1)) cos(q1)*sin(alpha(1)) cos(alpha(1)) cos(alpha(1))*d(1);
            0 0 0 1];

        T60 = (((T01)^(-1))*T)^(-1); 

        % Entonces, tenemos que
        Y60 = T60(1:3,2); % Sacamos los valores unitarios del eje y. 

        % Ahora, calculamos. 

        if sin(Theta5) ~=0 && Y60(2) ~=0

            Theta6 = atan2(Y60(2)/sin(Theta5),-Y60(1)/sin(Theta5)); 

        else
            Theta6 = 0;
        end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 3


        % Tenemos que encontrar una relacion entre el punto P14. Esto lo podemos
        % encontrar relacionando las matrices de transformacion. 

        % de 4 a 5 
        q5 = Theta5; 
        q6 = Theta6;

        T45 = [cos(q5) -sin(q5) 0 a(5);
            sin(q5)*cos(alpha(5)) cos(q5)*cos(alpha(5)) -sin(alpha(5)) -sin(alpha(5))*d(5);
            sin(q5)*sin(alpha(5)) cos(q5)*sin(alpha(5)) cos(alpha(5)) cos(alpha(5))*d(5);
            0 0 0 1];

        % de 5 a 6 

        T56 = [cos(q6) -sin(q6) 0 a(6);
            sin(q6)*cos(alpha(6)) cos(q6)*cos(alpha(6)) -sin(alpha(6)) -sin(alpha(6))*d(6);
            sin(q6)*sin(alpha(6)) cos(q6)*sin(alpha(6)) cos(alpha(6)) cos(alpha(6))*d(6);
            0 0 0 1];

        % Para poder encontrar una relacion entre 1 y 4, debemos, 
        T14 = ((T01)^(-1))*T*((T45*T56)^(-1)); % Tengo T10 * T06 * T64

        % Entonces, tenemos que. 

        P14xz = norm([T14(1,4) T14(3,4)]); % Norma de la componente en x y en z. 

        % Ahora, tenemos que encontrar donde estaria el punto 

        Theta3 = acos((((P14xz)^(2)) - ((a(3))^(2)) - ((a(4))^(2)))/(2*(abs(a(3))*(abs(a(4)))))); % Voy a quitar el abs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Encontrando THETA 2 -> Metodologia Parecida a Theta 1

        % Tenemos que, 
        P14 = T14(1:3,4); % tomamos los puntos del frame 4 visto desde el 1. 

        if P14(3) < 0 
            % Estoy en cuadrante 3 y 4 
            Theta2 = pi - abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) > 0 

            %Estoy en Cuadrante 1 y 2 
            Theta2 = pi + abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) == 0
            
            if P14(1) < 0
                % Si estamos en el cuadrante 2 pero con y = 0 
                Theta2 = (3*pi/2) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            else
                % Si estamos en x > 0
                Theta2 = (pi) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            end

        end

        % Si es mayor al complementario, tengo que encontrar el angulos
        % negativo que sigue :D 

        if Theta2 > pi
            Theta2 = -abs(2*pi - Theta2);
        end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando Theta 4 

        % Entonces, necesitamos la rotacion de 4 vista desde 3 

        % De 0 a 1

        q1 = Theta1; % Reemplazo el angulo

        T01 = [cos(q1) -sin(q1) 0 a(1);
            sin(q1)*cos(alpha(1)) cos(q1)*cos(alpha(1)) -sin(alpha(1)) -sin(alpha(1))*d(1);
            sin(q1)*sin(alpha(1)) cos(q1)*sin(alpha(1)) cos(alpha(1)) cos(alpha(1))*d(1);
            0 0 0 1];

        q2 = Theta2; % Reemplazo el angulo 

        % De 1 a 2 

        T12 = [cos(q2) -sin(q2) 0 a(2);
            sin(q2)*cos(alpha(2)) cos(q2)*cos(alpha(2)) -sin(alpha(2)) -sin(alpha(2))*d(2);
            sin(q2)*sin(alpha(2)) cos(q2)*sin(alpha(2)) cos(alpha(2)) cos(alpha(2))*d(2);
            0 0 0 1];

        q3 = Theta3; %Reemplazo el angulo

        % De 2 a 3


        T23 = [cos(q3) -sin(q3) 0 a(3);
            sin(q3)*cos(alpha(3)) cos(q3)*cos(alpha(3)) -sin(alpha(3)) -sin(alpha(3))*d(3);
            sin(q3)*sin(alpha(3)) cos(q3)*sin(alpha(3)) cos(alpha(3)) cos(alpha(3))*d(3);
            0 0 0 1];

        q5 = Theta5; % Reemplazo el angulo.

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


        % de 3 a 4

        T34 = ((T01*T12*T23)^(-1))*T*((T45*T56)^(-1)); % Saco la matriz de angulos.

        % Saco los puntos a evaluar. 

        Theta4 = atan2(T34(2,1),T34(1,1)); % Encuentro el angulo medido desde el eje x. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Organizando la matriz, tenemos que 
        % Tenemos que organizar los datos de manera que el Rviz lo entienda. 

        Theta = [Theta1, Theta2, Theta3, Theta4, Theta5, Theta6]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    else 
        
        %Si estamos entre 350 a 500
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 1 

        % Posicion de 5 vista desde el 0 
        P05 = T*[0;0;-d(6); 1];

        % Vamos a aproximar el valor de la posicoion debido a la precision manejada
        % en los parametros de D-H}

        valor = P05(2);
        precision = 4;
        factor = 10^precision;
        resultado = round(valor * factor) / factor;


        % Entonces, vamos a tomar la configuracion del angulo positivo, Para esto,
        % tenemos lo siguiente. 

        if resultado < 0

            % Tenemos la configuracion del 3 y 4 cuadrante. 
            Theta1 = pi - abs(atan2(P05(2),P05(1))) - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))));


        elseif resultado > 0

            % Tenemos la configuracion del 1 y 2 cuadrante. 
            Theta1 = pi + abs(atan2(P05(2),P05(1))) - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))));

        elseif resultado == 0

            if P05(1)<0
                % Si estamos en el cuadrante 2 pero con y = 0 
                Theta1 = (3*pi/2) + (pi/2 - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))))); 
            else
                % Si estamos en x > 0
                Theta1 = (pi) + (pi/2 - abs(asin((d(4))/(sqrt(((P05(1)^(2))+(P05(2)^(2)))))))); 
            end
        end 

        % Quedo lista

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Encontrando THETA 5 

        % Posicion del efector final en relacion con la base 
        P06 = [T(1:3,4)]; 

        % Estamos en cuadrante 3 y 4 

        % Estando en 3
        % Sacamos el origen de 6 visto en 1.
        P16 = abs(((rotz(Theta1))')*(P06));
       
        % Formulacion angulo 5 
        Theta5 = -abs(acos((P16(2) - d(4))/(d(6)))); % Tener presente que esta funcion limita la accion de Theta 5 de 0 a 90°. 

        % Quedo listo. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Encontrando THETA 6

        % Vamos primero a encontrar una relacion entre en marco 6 y el marco 1. 

        % Tenemos que 
        q1 = Theta1; 

        T01 = [cos(q1) -sin(q1) 0 a(1);
            sin(q1)*cos(alpha(1)) cos(q1)*cos(alpha(1)) -sin(alpha(1)) -sin(alpha(1))*d(1);
            sin(q1)*sin(alpha(1)) cos(q1)*sin(alpha(1)) cos(alpha(1)) cos(alpha(1))*d(1);
            0 0 0 1];

        T60 = (((T01)^(-1))*T)^(-1); 

        % Entonces, tenemos que
        Y60 = T60(1:3,2); % Sacamos los valores unitarios del eje y. 

        % Ahora, calculamos. 

        if sin(Theta5) ~=0 && Y60(2) ~=0

            Theta6 = atan2(Y60(2)/sin(Theta5),-Y60(1)/sin(Theta5)); 

        else
            Theta6 = 0;
        end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 3


        % Tenemos que encontrar una relacion entre el punto P14. Esto lo podemos
        % encontrar relacionando las matrices de transformacion. 

        q5 = Theta5; 
        q6 = Theta6;

        % De 4 a 5 

        T45 = [cos(q5) -sin(q5) 0 a(5);
            sin(q5)*cos(alpha(5)) cos(q5)*cos(alpha(5)) -sin(alpha(5)) -sin(alpha(5))*d(5);
            sin(q5)*sin(alpha(5)) cos(q5)*sin(alpha(5)) cos(alpha(5)) cos(alpha(5))*d(5);
            0 0 0 1];

        % de 5 a 6 

        T56 = [cos(q6) -sin(q6) 0 a(6);
            sin(q6)*cos(alpha(6)) cos(q6)*cos(alpha(6)) -sin(alpha(6)) -sin(alpha(6))*d(6);
            sin(q6)*sin(alpha(6)) cos(q6)*sin(alpha(6)) cos(alpha(6)) cos(alpha(6))*d(6);
            0 0 0 1];

        % Para poder encontrar una relacion entre 1 y 4, debemos, 
        T14 = ((T01)^(-1))*T*((T45*T56)^(-1)); % Tengo T10 * T06 * T64

        % Entonces, tenemos que. 

        P14xz = norm([T14(1,4) T14(3,4)]); % Norma de la componente en x y en z. 

        % Ahora, tenemos que encontrar donde estaria el punto 

        Theta3 = acos((((P14xz)^(2)) - ((a(3))^(2)) - ((a(4))^(2)))/(2*(abs(a(3))*(abs(a(4)))))); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Encontrando THETA 2 -> Metodologia Parecida a Theta 1

        % Tenemos que, 
        P14 = T14(1:3,4); % tomamos los puntos del frame 4 visto desde el 1. 

        if P14(3) < 0 
            % Estoy en cuadrante 3 y 4 
            Theta2 = pi - abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) > 0 

            %Estoy en Cuadrante 1 y 2 
            Theta2 = pi + abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) == 0
            if P14(1) < 0
                % Si estamos en el cuadrante 2 pero con y = 0 
                Theta2 = (3*pi/2) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            else
                % Si estamos en x > 0
                Theta2 = (pi) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            end

        end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando THETA 2 -> Metodologia Parecida a Theta 1

        % Tenemos que, 
        P14 = T14(1:3,4); % tomamos los puntos del frame 4 visto desde el 1. 

        if P14(3) < 0 
            % Estoy en cuadrante 3 y 4 
            Theta2 = pi - abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) > 0 

            %Estoy en Cuadrante 1 y 2 
            Theta2 = pi + abs(atan2(P14(3),P14(1))) - asin((abs(a(4))*sin(Theta3))/(P14xz)); % Calculamos el valor asociado. 

        elseif P14(3) == 0
            if P14(1) < 0
                % Si estamos en el cuadrante 2 pero con y = 0 
                Theta2 = (3*pi/2) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            else
                % Si estamos en x > 0
                Theta2 = (pi) + (pi/2 - abs(asin((abs(a(4))*sin(Theta3))/(P14xz)))); 
            end

        end

        % Si es mayor al complementario, tengo que encontrar el angulos
        % negativo que sigue :D 

        if Theta2 > pi
            Theta2 = -abs(2*pi - Theta2);
        end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Encontrando Theta 4 

        % Entonces, necesitamos la rotacion de 4 vista desde 3 

        % De 0 a 1

        q1 = Theta1; % Reemplazo el angulo

        T01 = [cos(q1) -sin(q1) 0 a(1);
            sin(q1)*cos(alpha(1)) cos(q1)*cos(alpha(1)) -sin(alpha(1)) -sin(alpha(1))*d(1);
            sin(q1)*sin(alpha(1)) cos(q1)*sin(alpha(1)) cos(alpha(1)) cos(alpha(1))*d(1);
            0 0 0 1];

        q2 = Theta2; % Reemplazo el angulo 

        % De 1 a 2 

        T12 = [cos(q2) -sin(q2) 0 a(2);
            sin(q2)*cos(alpha(2)) cos(q2)*cos(alpha(2)) -sin(alpha(2)) -sin(alpha(2))*d(2);
            sin(q2)*sin(alpha(2)) cos(q2)*sin(alpha(2)) cos(alpha(2)) cos(alpha(2))*d(2);
            0 0 0 1];

        q3 = Theta3; %Reemplazo el angulo

        % De 2 a 3


        T23 = [cos(q3) -sin(q3) 0 a(3);
            sin(q3)*cos(alpha(3)) cos(q3)*cos(alpha(3)) -sin(alpha(3)) -sin(alpha(3))*d(3);
            sin(q3)*sin(alpha(3)) cos(q3)*sin(alpha(3)) cos(alpha(3)) cos(alpha(3))*d(3);
            0 0 0 1];

        q5 = Theta5; % Reemplazo el angulo.

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


        % de 3 a 4

        T34 = ((T01*T12*T23)^(-1))*T*((T45*T56)^(-1)); % Saco la matriz de angulos.

        % Saco los puntos a evaluar. 

        Theta4 = atan2(T34(2,1),T34(1,1)); % Encuentro el angulo medido desde el eje x. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Organizando la matriz, tenemos que 
        % Tenemos que organizar los datos de manera que el Rviz lo entienda. 

        Theta = [Theta1, Theta2, Theta3, Theta4, Theta5, Theta6]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   end
   

end
