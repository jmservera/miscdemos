THIS_FILE := $(lastword $(MAKEFILE_LIST))
RG_NAME := OCPP
RG_LOCATION := switzerlandnorth
WEBAPP_NAME := $(shell az webapp list -g $(RG_NAME) --query "[0].name" -o tsv)
STORAGE_NAME := $(shell az storage account list -g $(RG_NAME) --query "[?starts_with(name,'webdeploy')].name" -o tsv)
EXPIRY := $(shell date -u -d "15 minutes" '+%Y-%m-%dT%H:%MZ')

preparecli:
	az upgrade
	az extension add --name webpubsub
	az bicep upgrade
	npm install -g @azure/web-pubsub-tunnel-tool
	@echo "Tools prepared, now you can start using the makefile"
build: $(wildcard api/**/*.cs)
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
start-tunnel:
	WebPubSubConnectionString='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	SubId='$(shell az account show --query "id" -o tsv)'; \
	awps-tunnel run --hub OcppService -c "$$WebPubSubConnectionString" -s $$SubId -g $(RG_NAME) --upstream http://localhost:5110
stop-tunnel:
	ps axf | grep awps-tunnel | grep -v grep | awk '{print "kill -9 " $$1}' | sh
infra: $(wildcard infra/**/*.bicep) $(wildcard infra/**/*.parameters.json)
	@echo "Deploying infra to Azure"
	az group create -n $(RG_NAME) -l $(RG_LOCATION)
	az deployment group create -g $(RG_NAME) --template-file infra/main.bicep --parameters infra/main.parameters.json
	@echo "Setting up user secrets"
	CONNECTION_STRING='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	dotnet user-secrets set 'WEBPUBSUB_SERVICE_CONNECTION_STRING' "$$CONNECTION_STRING" --project api/OcppServer/OcppServer.csproj	
secrets:
	CONNECTION_STRING='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	dotnet user-secrets set 'WEBPUBSUB_SERVICE_CONNECTION_STRING' "$$CONNECTION_STRING" --project api/OcppServer/OcppServer.csproj	
publish: $(wildcard api/**/*.cs) $(wildcard api/**/wwwroot/*)
	@echo "Creating publish files"
	dotnet publish api/OcppServer/OcppServer.csproj -c Release
	@echo "Zip files"
	cd api/OcppServer/bin/Release/net8.0/publish && zip -r /tmp/ocppserver.zip .
	@echo "Publish files created"
	az storage blob upload --account-name $(STORAGE_NAME) -c default -f /tmp/ocppserver.zip -n ocppserver.zip --overwrite;
	APP_URL='$(shell az storage blob generate-sas --full-uri --permissions r --expiry '$(EXPIRY)' --account-name $(STORAGE_NAME) -c default -n ocppserver.zip -o tsv)'; \
	az webapp deploy -g $(RG_NAME) -n $(WEBAPP_NAME) --src-url $$APP_URL --type zip;
deploy:
	@echo "Deploying all to Azure"
	@$(MAKE) -f $(THIS_FILE) infra
	# wait a little bit for the infra to be ready, to avoid publish errors with the gateway.
	@echo "Waiting for infra to be ready"
	sleep 60 
	@$(MAKE) -f $(THIS_FILE) publish
.PHONY: test clean watch start secrets
