# cursoDS

## Inicializar entorno docker
docker run -p 8888:8888 --name notebooks dsdh/data

## Inicializar docker con volume
docker run -p 8881:8888 -v //c/Users/DH/Documents/cursoDS:/home/DS-DH --name notebooks dsdh/data

## Copiar archivos dentro del container notebooks

docker cp clase1 data:/home/DS-DH
docker cp clase2 data:/home/DS-DH

