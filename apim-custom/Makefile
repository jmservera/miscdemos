build:
	dotnet build api/api.sln
clean:
	dotnet clean api/api.sln
restore:
	dotnet restore api/api.sln
watch:
	dotnet watch --project api/OcppServer/OcppServer.csproj run
start:
	dotnet run --project api/OcppServer/OcppServer.csproj
deploy:
	az deployment group create -g jmapim --template-file infra/main.bicep --parameters infra/main.parameters.json

