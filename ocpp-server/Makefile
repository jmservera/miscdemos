THIS_FILE := $(lastword $(MAKEFILE_LIST))
RG_NAME := OCPP
RG_LOCATION := switzerlandnorth
BICEP_PARAMS := main.parameters.bicepparam
WEBAPP_NAME := $(shell az webapp list -g $(RG_NAME) --query "[0].name" -o tsv)
STORAGE_NAME := $(shell az storage account list -g $(RG_NAME) --query "[?starts_with(name,'webdeploy')].name" -o tsv)
EXPIRY := $(shell date -u -d "15 minutes" '+%Y-%m-%dT%H:%MZ')
BASE_URI := $(shell cd infra && grep -Po "customDnsZoneName.*\K'(.+)'" $(BICEP_PARAMS) | grep -Po "[^']*")
WSSSUBDOMAIN := $(shell cd infra && grep -Po "pubsubARecordName.*\K'(.+)'" $(BICEP_PARAMS) | grep -Po "[^']*")
TEST_SERVER := $(WSSSUBDOMAIN).$(BASE_URI)
WEB_SERVER := www.$(BASE_URI)

preparecli:
	az upgrade
	az extension add --name webpubsub
	az bicep upgrade
	npm install -g @azure/web-pubsub-tunnel-tool
	@echo "Tools prepared, now you can start using the makefile"
build: build-api build-node
build-node: $(wildcard client/*.js)
	@echo "Building node client"
	cd client && npm install
build-api: $(wildcard api/**/*.cs)
	@echo "Building api"
	dotnet build api/api.sln
test:
	@echo "Testing"
	dotnet test api/api.sln
test-client:
	@echo "Testing a simple node client"
	node client/index.js wss://$(TEST_SERVER) station2 goodpwd
test-client-badauth:
	@echo "Testing a simple node client"
	node client/index.js wss://$(TEST_SERVER) station1 badpwd
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
infra: $(wildcard infra/**/*.bicep) $(wildcard infra/*.parameters.bicepparam)
	@echo "Deploying infra to Azure"
	az group create -n $(RG_NAME) -l $(RG_LOCATION)
	az deployment group create -g $(RG_NAME) --template-file infra/main.bicep --parameters infra/$(BICEP_PARAMS)
	@echo "Setting up user secrets"
	CONNECTION_STRING='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	dotnet user-secrets set 'WEBPUBSUB_SERVICE_CONNECTION_STRING' "$$CONNECTION_STRING" --project api/OcppServer/OcppServer.csproj	
secrets:
	CONNECTION_STRING='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	dotnet user-secrets set 'WEBPUBSUB_SERVICE_CONNECTION_STRING' "$$CONNECTION_STRING" --project api/OcppServer/OcppServer.csproj	
publish: $(wildcard api/**/*.cs) $(wildcard api/**/wwwroot/*)
	az webapp show -g $(RG_NAME) -n $(WEBAPP_NAME)
	@echo "Creating publish files"
	dotnet publish api/OcppServer/OcppServer.csproj -c Release
	@echo "Zip files"
	cd api/OcppServer/bin/Release/net8.0/publish && zip -r /tmp/ocppserver.zip .
	@echo "Publish files created"
	az storage blob upload --account-name $(STORAGE_NAME) -c default -f /tmp/ocppserver.zip -n ocppserver.zip --overwrite;
	APP_URL='$(shell az storage blob generate-sas --full-uri --permissions r --expiry '$(EXPIRY)' --account-name $(STORAGE_NAME) -c default -n ocppserver.zip -o tsv)'; \
	az webapp deploy -g $(RG_NAME) -n $(WEBAPP_NAME) --src-url $$APP_URL --type zip --track-status true;
	@echo "Waiting for webapp to be ready"
	until [ $$(curl -s -o /dev/null -w "%{http_code}" https://$(WEB_SERVER)) -eq 200 ]; do echo -n . && sleep 5; done
deploy:
	@echo "Deploying all to Azure"
	@$(MAKE) -f $(THIS_FILE) infra	
	@echo "Waiting for webapp to be ready"
	until [ $$(curl -s -o /dev/null -w "%{http_code}" https://$(WEB_SERVER)) -eq 200 ]; do echo -n . && sleep 5; done
	@$(MAKE) -f $(THIS_FILE) publish
.PHONY: test clean watch start secrets test-client infra
