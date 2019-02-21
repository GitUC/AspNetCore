FROM microsoft/aspnetcore:2.0 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /src
COPY ["api/api.csproj", "./api/"]
RUN dotnet restore "api/api.csproj"

COPY ["tests/tests.csproj", "./tests/"]
RUN dotnet restore "tests/tests.csproj"

COPY . .
# test
ENV TEAMCITY_PROJECT_NAME=fake
RUN dotnet test tests/tests.csproj

# publish
RUN dotnet publish api/api.csproj -o /publish

# Runtime stage
FROM base AS final
COPY --from=build-env /publish /publish
WORKDIR /publish
ENTRYPOINT ["dotnet", "api.dll"]