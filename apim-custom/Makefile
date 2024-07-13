THIS_FILE := $(lastword $(MAKEFILE_LIST))

build:
	@echo "Building"
	dotnet build api/api.sln
test:
	@echo "Testing"
	dotnet test api/api.sln
clean:
	@echo "Cleaning"
	dotnet clean api/api.sln
restore:
	@echo "Restoring packages"
	dotnet restore api/api.sln
watch:
	@echo "Starting OcppServer"
	dotnet watch --project api/OcppServer/OcppServer.csproj run
start:
	@echo "Starting OcppServer"
	dotnet run --project api/OcppServer/OcppServer.csproj
deploy:
	@echo "Deploying infra to Azure"
	az deployment group create -g jmapim --template-file infra/main.bicep --parameters infra/main.parameters.json
	# TODO: Get the name of the webapp and send it to the script
	@$(MAKE) -f $(THIS_FILE) publish
publish:
	@echo "Creating publish files"
	dotnet publish api/OcppServer/OcppServer.csproj -c Release
	@echo "Zip files"
	cd api/OcppServer/bin/Release/net8.0/publish && zip -r /tmp/ocppserver.zip .
	@echo "Publish files created"
	# TODO: Get the name of the webapp from a parameter
	az webapp deploy -g jmapim -n wapp-webapp-mgprxziwmupcg --src-path /tmp/ocppserver.zip

