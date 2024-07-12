build:
	dotnet build
clean:
	dotnet clean
restore:
	dotnet restore
watch:
	dotnet watch --project api/OcppServer/OcppServer.csproj run
start:
	dotnet run --project api/OcppServer/OcppServer.csproj
deploy:
	az deployment group create -g jmapim --template-file infra/main.bicep --parameters infra/main.parameters.json

