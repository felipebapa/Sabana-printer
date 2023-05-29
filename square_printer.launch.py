# Copyright (c) 2021 PickNik, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Alejandro Cortés, Libardo Zúñiga and Felipe Barreto
#
# Description: After a robot has been loaded, this will execute a series of trajectories for printing, after KURA.
import sys
from launch import LaunchDescription
from launch.substitutions import PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
from ament_index_python.packages import get_package_share_directory, PackageNotFoundError
import yaml

posiciones_nombres=[]
posiciones=[]
prefix='pos'
value=[]

# Obtener el valor actual de la variable de control
with open('/home/felipe/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/contador.txt', 'r') as f:
    contador = int(f.read())

# Lectura de los cada set de ángulos calculados con la cinemática inversa que permiten seguir los puntos generados en código G.
with open('/home/felipe/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/Angulos.txt', 'r') as archivo:
    for linea in archivo:
        # Eliminar los corchetes iniciales y finales de la línea
        linea = linea.strip()[1:-1]
        # Separar los ángulos por coma y convertirlos a float
        arreglo = [float(angulo) for angulo in linea.split(',')]
        posiciones.append(arreglo)


# Obtener la siguiente sección de 500 líneas de ángulos
inicio = contador * 500
fin = inicio + 500
angulos = posiciones[inicio:fin]
print(len(angulos))


joint_names=['shoulder_pan_joint','shoulder_lift_joint','elbow_joint','wrist_1_joint','wrist_2_joint',
             'wrist_3_joint']

#Recorremos el arreglo para así guardar el nombre de cada posición.
for i, element in enumerate(angulos,start=1):
    name = prefix + str(i)
    posiciones_nombres.append(name)


for i,element in enumerate(angulos):

    fila=posiciones_nombres[i]+': '+str(angulos[i])

    value.append(fila)


print(posiciones_nombres)
print(angulos)
#Guardamos en un dict la información que se almacenará en el .YALM

data = {
    'sabana_printer' : {
        'ros__parameters' : {
             'controller_name': 'joint_trajectory_controller',
             'wait_sec_between_publish' : 1, # Este parámetro no controla el tiempo entre punto a punto, sinó
                                                #que controla el tiempo para publicar.
             'goal_names' : posiciones_nombres,
             
             'joints' : joint_names,
             'check_starting_point' : True,
             'starting_point_limits' : {
                 'shoulder_pan_joint' : [-6.28,6.28],
                 'shoulder_lift_joint' : [-6.28,6.28],
                 'elbow_joint' : [-6.28,6.28],
                 'wrist_1_joint' : [-6.28,6.28],
                 'wrist_2_joint' : [-6.28,6.28],
                 'wrist_3_joint' : [-6.28,6.28]
                 }
        }
    } 
            }
    
for i,element in enumerate(angulos):
    
    dat={posiciones_nombres[i] : angulos[i]}
    data['sabana_printer']['ros__parameters'].update(dat)


with open('/home/felipe/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/printer_publisher_config.yaml', 'w') as f:
    yaml.dump(data, f,  default_flow_style=False)

with open('/home/felipe/workspace/ros_ur_driver/install/ur_bringup/share/ur_bringup/config/printer_publisher_config.yaml', 'w') as f:
    yaml.dump(data, f,  default_flow_style=False)


contador += 1
with open('/home/felipe/workspace/ros_ur_driver/src/Universal_Robots_ROS2_Driver/ur_bringup/config/contador.txt', 'w') as f:
    f.write(str(contador))


def generate_launch_description():
    
    print('\033[44m' + 'UNIVERSIDAD DE LA SABANA' + '\033[0m')
    print('\033[44m' + 'DOSISMEC - PRINTER' + '\033[0m')

    position_goals = PathJoinSubstitution(
        [FindPackageShare("ur_bringup"), "config", "printer_publisher_config.yaml"]
        
    )

    try:
        get_package_share_directory("ros2_control_test_nodes")
    except PackageNotFoundError:
        print(
            "ERROR:"
            "Could not find package 'ros2_control_test_nodes'. Please install it (build it from "
            "source) in order to run this launchfile. See here for details: explanation:\n"
            "https://github.com/UniversalRobots/Universal_Robots_ROS2_Driver/tree/foxy"
            "#example-commands-for-testing-the-driver"
        )
        sys.exit(1)

    return LaunchDescription(
        [
            Node(
                package="ros2_control_test_nodes",
                executable="sabana_printer",
                name="sabana_printer",
                parameters=[position_goals],
                output={"stdout": "screen", "stderr": "screen"},
            )
        ]
    )
