THIS_FILE := $(lastword $(MAKEFILE_LIST))
RG_NAME := OCPP
RG_LOCATION := switzerlandnorth
BICEP_PARAMS := main.parameters.bicepparam

export RG_NAME
export RG_LOCATION
export BICEP_PARAMS

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
	@$(MAKE) -f make/webapp.mk test-client
test-client-badauth:
	@$(MAKE) -f make/webapp.mk test-client-badauth
clean:
	@echo "Cleaning"
	dotnet clean api/api.sln
clean-all:
	@echo "Cleaning all"
	dotnet clean api/api.sln
	rm -rf client/node_modules
	rm -rf api/OcppServer/bin
	rm -rf api/OcppServer/obj
	rm -rf /tmp/ocppserver.zip
	@$(MAKE) -f $(THIS_FILE) clean-infra
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
	@$(MAKE) -f $(THIS_FILE) secrets
clean-infra:
	az group delete -n $(RG_NAME)
secrets:
	CONNECTION_STRING='$(shell az webpubsub list -g $(RG_NAME) --query "[0].name" -o tsv | az webpubsub key show -g $(RG_NAME) -n @- --query "primaryConnectionString" -o tsv)'; \
	dotnet user-secrets set 'WEBPUBSUB_SERVICE_CONNECTION_STRING' "$$CONNECTION_STRING" --project api/OcppServer/OcppServer.csproj	
publish: $(wildcard api/**/*.cs) $(wildcard api/**/wwwroot/*)
	@$(MAKE) -f make/webapp.mk publish
restart:
	@$(MAKE) -f make/webapp.mk restart
deploy:
	@echo "Deploying all to Azure"
	@$(MAKE) -f $(THIS_FILE) infra	
	@$(MAKE) -f make/webapp.mk restart
	@$(MAKE) -f make/webapp.mk publish
.PHONY: test clean watch start secrets test-client infra clean-infra restart
