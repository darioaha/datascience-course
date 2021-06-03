REGISTRY_REPO=gitlab.siu.edu.ar:5005
IMAGE_NAME=$(REGISTRY_REPO)/dalonso/ds:develop

NOMBRE_RED=py_net
TEST_PORT=8283
INSTANCIA_APP=py_ds_dev

build: Dockerfile ## Construye la imagen
	docker build -t $(IMAGE_NAME) .

upload: build
	docker login $(REGISTRY_REPO)
	docker push $(IMAGE_NAME)

init:
	@echo "Corriendo contenedor python"
	docker run -d -it \
	--network=$(NOMBRE_RED) \
	-p $(TEST_PORT):80 \
	--name=$(INSTANCIA_APP) $(IMAGE_NAME)



