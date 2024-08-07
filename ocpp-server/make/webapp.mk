STORAGE_NAME := $(shell az storage account list -g $(RG_NAME) --query "[?starts_with(name,'webdeploy')].name" -o tsv)
WEBAPP_NAME := $(shell az webapp list -g $(RG_NAME) --query "[0].name" -o tsv)
EXPIRY := $(shell date -u -d "15 minutes" '+%Y-%m-%dT%H:%MZ')
BASE_URI := $(shell cd infra && grep -Po "customDnsZoneName.*\K'(.+)'" $(BICEP_PARAMS) | grep -Po "[^']*")
WSSSUBDOMAIN := $(shell cd infra && grep -Po "pubsubARecordName.*\K'(.+)'" $(BICEP_PARAMS) | grep -Po "[^']*")
ifeq ($(BASE_URI),)
	TEST_SERVER := $(shell az network public-ip list -g $(RG_NAME) --query "[0].dnsSettings.fqdn" -o tsv)
	WEB_SERVER := 
	PROTOCOL := ws
else
	TEST_SERVER := $(WSSSUBDOMAIN).$(BASE_URI)
	WEB_SERVER := www.$(BASE_URI)
	PROTOCOL := wss
endif

testvars:
	@echo -e RG_NAME=\'$(RG_NAME)\'
	@echo -e BASE_URI=\'$(BASE_URI)\'
	@echo -e WSSSUBDOMAIN=\'$(WSSSUBDOMAIN)\'
	@echo -e TEST_SERVER=\'$(TEST_SERVER)\'
	@echo -e WEB_SERVER=\'$(WEB_SERVER)\'
test-client:
	@echo "Testing a simple node client"
	node client/index.js $(PROTOCOL)://$(TEST_SERVER) station2 goodpwd
test-client-badauth:
	@echo "Testing a simple node client"
	node client/index.js $(PROTOCOL)://$(TEST_SERVER) station1 badpwd
publish:
	@echo "Creating publish files"
	dotnet publish api/OcppServer/OcppServer.csproj -c Release
	@echo "Zip files"
	cd api/OcppServer/bin/Release/net8.0/publish && zip -r /tmp/ocppserver.zip .
	@echo "Publish files created"
	az storage blob upload --account-name $(STORAGE_NAME) -c deployments -f /tmp/ocppserver.zip -n ocppserver.zip --overwrite;
	APP_URL='$(shell az storage blob generate-sas --full-uri --permissions r --expiry '$(EXPIRY)' --account-name $(STORAGE_NAME) -c deployments -n ocppserver.zip -o tsv)'; \
	if az webapp deploy -g $(RG_NAME) -n $(WEBAPP_NAME) --src-url $$APP_URL --type zip; then \
		echo "Deployed to Azure"; \
	else \
		echo "Check deployment, first time can fail with Gateway Timeout but still be successful"; \
		sleep 20; \
		if [ $$(curl -s -o /dev/null -w "%{http_code}" https://$(WEB_SERVER)/health) -eq 200 ]; then \
			echo "Webapp is already deployed"; \
		else \
			# todo: check status with the rest api https://management.azure.com/subscriptions/$$(az account show --query id -o tsv)/resourceGroups/RESOURCEGROUP/providers/Microsoft.Web/sites/WEBAPPNAME/deployments?api-version=2023-12-01 \
			echo "Retry deployment, first time can fail with Gateway Timeout"; \
			sleep 10; \
			az webapp deploy -g $(RG_NAME) -n $(WEBAPP_NAME) --src-url $$APP_URL --type zip; \
		fi; \
	fi
ifneq ($(WEB_SERVER),)
	@echo "Waiting for webapp to be ready"
	@sleep 5
	until [ $$(curl -s -o /dev/null -w "%{http_code}" https://$(WEB_SERVER)/health) -eq 200 ]; do echo -n . && sleep 5; done
	@echo
endif

restart:
	az webapp stop -g $(RG_NAME) -n $(WEBAPP_NAME)
	sleep 5
	az webapp start -g $(RG_NAME) -n $(WEBAPP_NAME)
	sleep 5

.PHONY: publish restart test-client test-client-badauth testvars