 %% Proyecto Dosis.

% El script que se tiene, se trabajara para el proyecto de diseño mecanico
% en enfasis para la carrera de Ingenieria Mecanica de la Universidad de la
% Sabana. Todo con el fin de obtener el titulo de Ingeniero Mecanico. 

% David Alejandro Cortes.
% Felipe Barreto Patiño. 
% libardo Andrés Zúñiga

% Vamos a correr el codigo de iniciacion 
run("startup_rvc.m");

% Inicializacion de comandos. 
clc
close all
clear all

% Formato a utilizar para la salida de los textos 
format shortE


%% Inicializacion de variables.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cargo el modelo del robot. 
mdl_ur5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables de posisionamiento

linea = 1; % Inicializo la variable de linea utilizada para ubicar las posiciones. 
inicio = 0; % Inicio de la matriz
iniciom = 0; % Inicio de los puntos intermedios

% Valores de ciclos. 
numRows = 0; % Para sacar el valor de la matriz de codigo G. 
numRowsA = 0; % Para sacar el valor de la matriz de Arduino. 
rows(1,1) = 0; % Para eliminar los 0 


% Vectores de velocidad, material y aceleracion. 
fpos= 0; % Feedrate del robot. 

% Vectores de posicion
xpos = 0;
ypos = 0;
zpos = 0;

% Vairables de edicion del codigo. 
indicador = 1; % indicador de posicion. 

% Variable de tiempo
tiempo = 0; % Variable de tiempo del programa. 
Tiempo(1,1) = 1; % matriz de tiempo. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables de Diseño

% Factor de reduccion para los codigos g
Factor = 1/1000; % Factor de reduccion 

% Creacion del home del robot. 
qimpresion2  = [0 -pi/2 0 -pi/2 0 0];

%% Offset de la herramienta de trabajo. 

% Ofset del cabeza de impresion
xoffset = 40; % Valor en mm
xoffset = xoffset * Factor; % Valor en m. 

yoffset = 40;% valor en mm 
yoffset = (yoffset * Factor) - (1.72 * Factor); % Valor en m. 

zoffset = 0; % Valor en mm.
zoffset = zoffset * Factor; % Valor en m. 

% Offset del robot. 
Hoffset = 364.28; % en mm  En la mesa para el extrusor 342, para el marcador 320, con el vidrio 371.10
Hoffset = (Hoffset * Factor) + (1.9*Factor); % m. 

% Tamaño del hueco. 
Hueco = 20; % Para que el robot sepa lo que es un hueco, esta medida esta en mm (50) 
Hueco = Hueco * Factor; % Para el robot, el hueco se considerara como un valor en m. 

% Cantidad de interpolaciones a realizar. 
interpolacion = 40; %interpolaion inicial
interpolacion_media = 100; % interpolacion de puntos medios (100) 

%% Extrasion del codigo G -> Vamos a hacer una prueba con Griffin.  

% Inclusion de la libreria en el Matlab. 

fid = fopen('Configuraciones Extras/Configuraciones_rapidas/Cubo_Solido_500_500_Cuadrante4_2_19.gcode', 'r', 's'); % Extraigo el archivo de codigo g 
tline = fgets(fid); % Excluye el caracter de nueva linea -> Primera linea de codigo. 

% Extraigo las lineas de codigo G. 
while ischar(tline)

    % Vamos a hacer el reconocimiento de las variables.
    words = strsplit(tline, ' '); % Separo las variables en un espacio
    words2 = strsplit(tline, ':'); % Separo las variables por : 

    for i = 1:length(words) % Miramos lo que contiene cada parte del código. 

           switch words{i}(1:end) % Miramos cada caso, 

               %Caso de G0, este va a compañado de las condiciones de X,
               %Y y Z así como las condiciones de Feedrate. 

               case 'G0' 
                  % Tenemos G0 F9000 X126.334 Y157.703 (ok) , G0 Z20.001 (ok) y G0
                  % X125.215 Y80.215 y G0 F600 X126.554 Y158.232 Z0.35 (ok)  

                   if words{2}(1) == 'F' && length(words) <= 4 % Acá quiero que se mueva en x y y rápido G0 F9000 X126.334 Y157.703 (ok)
                       
                       % Almacenamos los valores correspondientes
                        fpos = str2double(words{2}(2:end));
                        xpos = str2double(words{3}(2:end));
                        ypos = str2double(words{4}(2:end));

                        matriz_codigo_g (linea,1) = xpos * (Factor); 
                        matriz_codigo_g (linea,2) = ypos * (Factor); 
                        matriz_codigo_g (linea,3) = zpos * (Factor);
                        Arduino (linea,4) = fpos; 

                   elseif words{2}(1) == 'F' && length(words) > 4  %Acá, quiero que se mueva rápido en las posiciones x, y y z G0 F600 X126.554 Y158.232 Z0.35 (ok) R
                       %REVISAR. 
                       %Almacenamos los valores correspondientes
                        fpos = str2double(words{2}(2:end));
                        xpos = str2double(words{3}(2:end));
                        ypos = str2double(words{4}(2:end));
                        zpos = str2double(words{5}(2:end)); 

                        matriz_codigo_g (linea,1) = xpos * Factor; 
                        matriz_codigo_g (linea,2) = ypos * Factor; 
                        matriz_codigo_g (linea,3) = zpos * (Factor);
                        Arduino (linea,4) = fpos; 

                   elseif words{2}(1) == 'Z' % Solo quiero que se mueva rápido en z, para eso, que se quede quieto en X y Y. 
                       % Almacenamos los valores correspondientes
                        zpos = str2double(words{2}(2:end)); % En los códigos G01, no se tiene posición en Z  G0 Z20.001 (ok) 
                        matriz_codigo_g (linea,1) = xpos * Factor; 
                        matriz_codigo_g (linea,2) = ypos * Factor; 
                        matriz_codigo_g (linea,3) = zpos * (Factor);

                   elseif words{2}(1) == 'X' && length(words) <= 3 % Si tenemos el movimeinto rápido solo con G0 X125.215 Y80.215

                       % Almacenamos los valores correspondientes
                       xpos = str2double(words{2}(2:end));
                       ypos = str2double(words{3}(2:end));


                     % Almaceno los valores en una matriz. 
                        matriz_codigo_g (linea,1) = xpos * Factor; 
                        matriz_codigo_g (linea,2) = ypos * Factor; 
                        matriz_codigo_g (linea,3) = zpos * (Factor);

                   end 
              

              % Caso de G1, este va a compañado de las condiciones de X y
              % Y así como las condiciones de Feedrate y Extrusión de
              % material.

               case 'G1' % Si la primera parte el G01

                 if words{2}(1) == 'X' % Busque en la segunta parte, si es X, almacene. 
                    xpos = str2double(words{2}(2:end));
                    ypos = str2double(words{3}(2:end));
                    Epos = str2double(words{4}(2:end)); % Extraigo el valor de la cantidad de material que debo extraer.

                    %Almaceno los valores en una matriz. 

                    matriz_codigo_g (linea,1) = xpos * Factor; 
                    matriz_codigo_g (linea,2) = ypos * Factor; 
                    matriz_codigo_g (linea,3) = zpos * (Factor);
                    Arduino(linea,1) = Epos;  

                 elseif words{2}(1) == 'F' % if the word starts with feedrate

                     if length(words) > 3 % Existen 2 Casos, Cuando se tiene G1 F2700 E0 o G1 F1350 X210.593 Y164.174 E0.00939
                        fpos = str2double(words{2}(2:end));
                        xpos = str2double(words{3}(2:end));
                        ypos = str2double(words{4}(2:end));
                        Epos = str2double(words{5}(2:end)); % Extraigo el valor de las cantidad de material. 

                        matriz_codigo_g (linea,1) = xpos * Factor; 
                        matriz_codigo_g (linea,2) = ypos * Factor; 
                        matriz_codigo_g (linea,3) = zpos * (Factor);
                        Arduino(linea,1) = Epos; % Almaceno el valor de la cantidad de material que tiene que extruir. 
                        Arduino (linea,4) = fpos; 

                     elseif length(words) <= 3 
                         fpos = str2double(words{2}(2:end));
                         Epos = str2double(words{3}(2:end));

                         Arduino(linea,1) = Epos; % Pongo el valor de la cantidad de material que hay que extruir. 
                         Arduino (linea,4) = fpos; 

                     end % End del if 
                     
                 end % End del if anterior


                % Información del arduino: Para este caso, vamos a pasarle
                % la información de la siguiente manera, 
                % Arduino = [Cantidad de material, Velocidad del ventilador, Temperatura del extrusor. ] 
               case 'M106'

                   Arduino(linea,2) = str2double(words{2}(2:end)); % Extraigo la velocidad del ventilador.


               case 'M109'

                   Arduino(linea,3) = str2double(words{2}(2:end)) ; % Almaceno en la matriz de arduino.

              
           end % End del switch

    end % End del for. 

    for j= 1:length(words2)

        switch words2{j}(1:end)
            case ';TIME_ELAPSED'
            tiempo = str2double(words2{2}(1:end));
        end
        
    end


  %  Siguiente linea, 
    tline = fgets(fid);  % Siguiente linea,
        linea = linea + 1; % aumento el valor de la línea. 

end

fclose(fid); % Cierro la comunicación. 

% Determinación de las variables de los puntos asociados . 
[numRows,~] = size(matriz_codigo_g);
[numRowsA,~] = size(Arduino);


% Pirmero, debo editar la matriz para que, depsues del punto inicial, busque los 0,0,0 y ponga los puntos anteriores a estos. 

for i = 1:numRows

    matriz_codigo_g(i,4) = 0; % Meto la columna de saber si hay o no angulos extras.

    if matriz_codigo_g(i,1) ~= 0 && matriz_codigo_g(i,2) ~= 0 % Si X, Y son iguales a 0.
        rows(end+1,1) = i;
    end 

end 

% Edito la matriz
matriz_codigo_g =  matriz_codigo_g(rows(2:end),:);

% Edito el tamaño. 
[numRows,~] = size(matriz_codigo_g);

% Ahora, tengo que duplicar la utlima linea de codigo cada 500 datos. 

%% Realizo a correccion de "Huecos" 

% Para arreglar los "Huecos", vamos a configurar el robot para que la
% distancia entre puntos no sea mayor a la distancia de Huecos.

% Necesitamos una matriz que me indicque si hay o no una configuracion
% adicional de agujeros. 

% Necesitamos una matriz que almacene los angulos nuevos a configurar. 

% Necesitamos una variable que me ayude a saber cuantos angulos va a
% indicar. 

% Variables a utilizar. 
% Existencia = 0; % Ayudara a indicar si hay o no angulos extras.  
% cantidad. 

for i = 1:(numRows-1)

    % Primero, necesitamos mirar si la distancia entre el punto actual y el
    % siguiente es mayor al hueco. 

    distancia = abs(norm(matriz_codigo_g(i,1:3)-matriz_codigo_g(i+1,1:3))); % Miro la distancia entre los datos. 

    if distancia > Hueco
        % Edito la matriz. 
        % Edito la nueva matriz. 
        matriz_codigo_g(i,4) = 1; 
        

        % 1. Cuantos puntos son necesarios? 
        %interpolacion_media = ceil(distancia/Hueco);  
                

        % Armo las matrices. 
        T1 = [[1 0 0; 0 -1 0; 0 0 -1] [matriz_codigo_g(i,1)+xoffset; matriz_codigo_g(i,2)+yoffset;matriz_codigo_g(i,3)+zoffset+Hoffset];[0 0 0] 1];
        T2 = [[1 0 0; 0 -1 0; 0 0 -1]  [matriz_codigo_g(i+1,1)+xoffset; matriz_codigo_g(i+1,2)+yoffset;matriz_codigo_g(i+1,3)+zoffset+Hoffset];[0 0 0] 1];

        % Realizamos la interpolacion lineal. 
        tg = ctraj(T1,T2,interpolacion_media);

        for j = 1:interpolacion_media
            % Almaceno en una matriz nueva. 
            matriz_puntos_intermedios(:,:,indicador) = tg(:,:,j); % Almaceno las matrices de transformacion. 
            indicador = indicador+1; % Sumo 1 al valor de indicador. 
        end


    else 
        % No edito nada.
        matriz_codigo_g(i,4)  = 0;

    end 

end


%% Transformacion, inversa y plot para HOME PRINT

% Para este poryecto, tenemos tres problemas: 
% 1. Tenemos que identiicar cuando el robot empezara a trabajar. 
% 2. Antes de eso, debe llegar desde la posicion de Home hasta la posicion de inicio de trabaj. 
% 3. Sumado a esto, despues, debemos hacer que siga trayectorias de movimiento. 


% VAMOS A TRABAJAR DESDE EL HOME HASTA EL PUNTO DE IMPRESION.

% Realizao la matriz de rotacion

T = transl(matriz_codigo_g(1,1)+xoffset,matriz_codigo_g(1,2)+yoffset, matriz_codigo_g(1,3)+zoffset+Hoffset) *rpy2tr(pi,0.0,0.0); % Genero matriz de rotacion necesaria. 


% Si se quiere alcanzar una orientacion   
% del efector perpenticular al plano
% Se debe especificar un Tprint
% -0.5 <= x <= 0.5 ;
% -0.5 <= y <= 0.5 ;
% -0.1 <= z <= 0.4 ;
 

% Realizo una linealizacion desde el home hasta el punto de rotacion con linealizacion cartecianas.

tg = analitica(T); % Interpolacion con los joints del robot. 
q = jtraj(qimpresion2,tg,interpolacion);

for j = 1:interpolacion

       % Para jtraj.
       matriz(j,1:6) = q(j,1:6); % Extraigo los angulos. 
       
end

% Calculo las distancias
for i = 1:interpolacion-1

    % Primero, tomo los puntos x,y,z
    [~,~,~,P1] = cinematica_directa(q(i,1),q(i,2),q(i,3),q(i,4),q(i,5),q(i,6));
    [~,~,~,P2] = cinematica_directa(q(i+1,1),q(i+1,2),q(i+1,3),q(i+1,4),q(i+1,5),q(i+1,6));

    % Tomo los valores de X,Y y Z
    P1 = P1(1:3,4);
    P2 = P2(1:3,4);

    % Saco la distancia. 
    distancia(i,1) = norm(P2-P1);  % distancias en metros. 

end

%% Formulacion Analitica del problema. 

% Comienzo del ciclo
for i= 1+1:numRows

    if matriz_codigo_g(i,4) == 0

        % Extraigo los valores de x, y y z.

        x = matriz_codigo_g (i,1);
        y = matriz_codigo_g (i,2);
        z = matriz_codigo_g (i,3);


        T = [ [1 0 0; 0 -1 0; 0 0 -1] [x+xoffset;y+yoffset;z+zoffset+Hoffset]; [0 0 0] 1]; % Solo me enfoco en la translacion del efector final.
        
        % Miramos el tamaño de la matriz
        [inicio, ~] = size(matriz); % Que siempre agarre el valor del ultimo loguar de la matriz

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [Theta] = analitica(T);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Organizando la matriz, tenemos que 
        matriz(inicio + 1,1:6) = Theta(1,1:6);
        

    else

        % Analice los angulos intermedios. Voy a reciclar la variable
        % inicio. 

        for j=1:interpolacion_media-1
            % Primero saco los angulos. 
            [Theta] = analitica(matriz_puntos_intermedios(:,:,iniciom+j));

            % Miramos el tamaño de la matriz
            [inicio, ~] = size(matriz); % Que siempre agarre el valor del ultimo lugar de la matriz.

            % introduzco los valores del angulo. 
            matriz(inicio+1,1:6) = Theta(1,1:6);           

        end                 

         % Edito el valor de inicio. 
         iniciom = iniciom + interpolacion_media;

    end 
    
    % vamos a mirar el tamaño de la matriz. 
    [final,~] = size(matriz); 

    if rem(final, 500) == 0
        matriz(final+1,1:6)=matriz(final,1:6);
    end

end


%% Correcion 

[rows,~] = size(matriz);

for i = 1:rows
    for j = 1:6 
        
        if matriz(i,j) == 0 
            matriz(i,j) = 0.0; 
        end 
       
    end
end


%% Calculo de distancia. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = interpolacion:rows-1

        % Ajusto el valor de los tiempos
        [inicio,~] = size(distancia);

        % Calculo la velocidad actual                
        % Metodo 1
        [~,~,~,P1] = cinematica_directa(matriz(i,1),matriz(i,2),matriz(i,3),matriz(i,4),matriz(i,5), matriz(i,6)); % Primer punto a evlauar.
        [~,~,~,P2] = cinematica_directa(matriz(i+1,1),matriz(i+1,2),matriz(i+1,3),matriz(i+1,4),matriz(i+1,5), matriz(i+1,6)); % Seguno punto a evlauar

        % Tomo los valores de las posiciones
        P1 = P1(1:3,4); % Tomo los valores X,Y,Z
        P2 = P2(1:3,4); % Tomo los valores X,Y,Z

        % Calculo la distancia
        distancia(inicio+1,1) = norm(P2-P1);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Desde el ultimo punto hasta el home de impresion. 

% Esto es para que el robot pase desde el utlimo punto de impresion hasta
% el home del robot, para que podamos determinar si ya termino la
% impresion.

T = transl(matriz_codigo_g(end,1)+xoffset,matriz_codigo_g(end,2)+yoffset, matriz_codigo_g(end,3)+zoffset+Hoffset+(50*Factor)) *rpy2tr(pi,0.0,0.0); % Genero matriz de rotacion necesaria. 

% Realizo la interpolacion. 
tg = analitica(T); % Interpolacion con los joints del robot. 
q = jtraj(tg,qimpresion2,interpolacion);


for i = 1:interpolacion

    % Extraigo los valores del tamaño de la matriz.
    [inicio,~] = size(matriz);
       
    % Para jtraj.
    matriz(inicio+1,1:6) = q(i,1:6); % Extraigo los angulos.
end

% duplico la ultima linea de datos de angulos dado a la ultima limitante de
% datos que tengo. 
matriz(end+1,1:6) = matriz(end,1:6);

% Saco el tiempo, 
% Edito el valor de inicio para la matriz. 
[inicio,~] = size(matriz);

for i = inicio-(interpolacion+1):inicio-1

        % Ajusto el valor de los tiempos
        [inicio2,~] = size(distancia);

        % Calculo la velocidad actual                
        % Metodo 1
        [~,~,~,P1] = cinematica_directa(matriz(i,1),matriz(i,2),matriz(i,3),matriz(i,4),matriz(i,5), matriz(i,6)); % Primer punto a evlauar.
        [~,~,~,P2] = cinematica_directa(matriz(i+1,1),matriz(i+1,2),matriz(i+1,3),matriz(i+1,4),matriz(i+1,5), matriz(i+1,6)); % Seguno punto a evlauar.

        % Tomo la parte de posiciones. 
        P1 = P1(1:3,4);
        P2 = P2(1:3,4);
        

        distancia(inicio2+1,1) = norm(P2-P1);
end

% convierto de m a mm 
distancia(1:end,1) = distancia(1:end,1) * (1/Factor); 


%% Edito la matriz de angulos. 

% Suponiendo que el arreglo se llama "Angulos"
filename = '/home/libardo/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/Angulos.txt';

delimiter = ','; % delimitador que separa los valores (puedes cambiarlo por el que necesites)
formatSpec='%g, %g, %g, %g, %g, %g';
% Abre el archivo para escritura
fid = fopen(filename, 'w');

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, '[');

% Escribe los valores de la primera fila separados por el delimitador. Nos
% saltamos el HOME. (tg(2,:)). SI quiere que empieze por el home, poner
% desde 1.
fprintf(fid, formatSpec, matriz(1,:));

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, ']\n');

% Escribe las llaves rectangulares para las filas restantes
for i = 2:50  %size(matriz,1)
    fprintf(fid, '[');
    fprintf(fid, formatSpec, double(matriz(i,:)));
    fprintf(fid, ']\n');
end

% Cierra el archivo.
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Edito la Matriz de Arduino.

filename = '/home/libardo/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/Arduino.txt';

delimiter = ','; % delimitador que separa los valores (puedes cambiarlo por el que necesites)
formatSpec='%g, %g, %g, %g,';
% Abre el archivo para escritura
fid = fopen(filename, 'w');

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, '[');

% Escribe los valores de la primera fila separados por el delimitador. Nos
% saltamos el HOME. (tg(2,:)). SI quiere que empieze por el home, poner
% desde 1.
fprintf(fid, formatSpec, Arduino(1,:));

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, ']\n');

% Escribe las llaves rectangulares para las filas restantes
for i = 2:size(Arduino,1)
    fprintf(fid, '[');
    fprintf(fid, formatSpec, double(Arduino(i,:)));
    fprintf(fid, ']\n');
end

% Cierra el archivo.
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Edito la matriz de las distancias, 

filename = '/home/libardo/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/distancia.txt';

delimiter = ','; % delimitador que separa los valores (puedes cambiarlo por el que necesites)
formatSpec='%g';
% Abre el archivo para escritura
fid = fopen(filename, 'w');

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, '[');

% Escribe los valores de la primera fila separados por el delimitador. Nos
% saltamos el HOME. (tg(2,:)). SI quiere que empieze por el home, poner
% desde 1.
fprintf(fid, formatSpec, distancia(1,:));

% Escribe las llaves rectangulares para la primera fila
fprintf(fid, ']\n');

% Escribe las llaves rectangulares para las filas restantes
for i = 2:size(distancia,1)
    fprintf(fid, '[');
    fprintf(fid, formatSpec, double(distancia(i,:)));
    fprintf(fid, ']\n');
end

% Cierra el archivo.
fclose(fid);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Edito Contador.


filename = '/home/libardo/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/contador.txt';

delimiter = ','; % delimitador que separa los valores (puedes cambiarlo por el que necesites)
formatSpec='%g';
% Abre el archivo para escritura
fid = fopen(filename, 'w');

% Escribe los valores de la primera fila separados por el delimitador. Nos
% saltamos el HOME. (tg(2,:)). SI quiere que empieze por el home, poner
% desde 1.
fprintf(fid, formatSpec, 0);

fclose(fid);

disp('Termine de ejecutar los angulos')



