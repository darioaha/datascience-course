# cursoDS

## Inicializar entorno docker

### Comando general
docker run -p 8888:8888 --name notebooks dsdh/data

### Inicializar docker con volume
docker run -p 8888:8888 -v //c/Users/DH/Documents/cursoDS:/home/DS-DH --name notebooks dsdh/data
- //c/Users/DH/Documents/cursoDS es el directorio de windows donde se clono el repo

### Correr contenedor al reiniciar equipo
docker start notebooks

### Copiar archivos dentro del container notebooks
docker cp clase1 notebooks:/home/DS-DH
docker cp clase2 notebooks:/home/DS-DH

