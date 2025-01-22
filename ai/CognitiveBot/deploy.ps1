Remove-Item *.zip
dotnet build .\CognitiveBot.sln
Remove-Item -Recurse -Force .\bin
Remove-Item -Recurse -Force .\obj
Compress-Archive -Path .\* -DestinationPath .\CognitiveBot.zip
az webapp deploy -g demos --name jmcognitivebot01 --src-path .\CognitiveBot.zip
dotnet build .\CognitiveBot.sln