HOME_CODE_SERVER_DIR ?= $(HOME)/.code-server

get-code-server:
	@echo;echo "Getting code-server..."
	-docker rm -f codercom
	docker run -d --name codercom codercom/code-server:4.16.0
	-docker cp codercom:/usr/lib/code-server $(HOME_CODE_SERVER_DIR)
	docker rm -f codercom
	@echo;echo "code-server downloaded successfully"


start-code-server:
	@echo;echo "Starting code-server..."
	mkdir -p $(HOME)/workspace
	$(HOME_CODE_SERVER_DIR)/bin/code-server -e \
		--auth password \
		--bind-addr 0.0.0.0:8487 \
		$(HOME)/workspace

	@echo "code-server started successfully"


# --extensions-dir $(HOME_CODE_SERVER_DIR)/extensions \
# --disable-telemetry \