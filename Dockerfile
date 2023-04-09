FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /source

COPY ./*.csproj .
RUN dotnet restore 

# COPY from Source to Container, dot mean current directory for both source and container
COPY . .
RUN dotnet publish -c release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:7.0

RUN apt-get update
RUN apt-get install -y nginx
COPY nginx/default.conf /etc/nginx/sites-enabled/default
# Another way is replace nginx.conf directly but more code need to specify
#COPY nginx/nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
COPY --from=build /app ./
ENV ASPNETCORE_URLS=http://+:5000
# This will execute during docker run, start NGINX service and run .NET
CMD ["/bin/bash", "-c", "service nginx start && dotnet aspnetdocker.dll"]
# Another way is use shell script
#COPY nginx/startup.sh /scripts/startup.sh
#RUN ["chmod", "+x", "/scripts/startup.sh"]
#ENTRYPOINT ["/scripts/startup.sh"]
# Below can't work because Nginx will block dotnet from execute
#CMD ["/bin/bash", "-c", "nginx -g 'daemon off;' && dotnet aspnetdocker.dll"]

# Use this if run .NET only without NGINX
#ENTRYPOINT [ "dotnet", "aspnetdocker.dll" ]
#CMD ["/bin/bash", "-c", "dotnet aspnetdocker.dll"]

# Use this if run NGINX only without .NET
#ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
# The methods on below will not working for NGINX since it is non-daemon/blocking
#ENTRYPOINT [ "service", "nginx", "start" ]
#CMD ["service", "nginx", "start"]
