## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm, with the ability to pull website code from git. The container also has the ability to update templated files with vaiables passed to docker in order to update your settings.

### Git repository
The source files for this project can be found here: [https://github.com/ngineered/nginx-php-fpm](https://github.com/ngineered/nginx-php-fpm)

If you have any improvements please submit a pull request.
### Docker hub repository
The Docker hub build can be found here: [https://registry.hub.docker.com/u/richarvey/nginx-php-fpm/](https://registry.hub.docker.com/u/richarvey/nginx-php-fpm/)
## Versions
| Tag | Nginx | PHP | Alpine |
|-----|-------|-----|--------|
| latest | 1.10.1 | 5.6.21 | 3.4 |
| php5 | 1.10.1 | 5.6.21 | 3.4 |
| php7 | 1.10.1 | 7.0.7 | 3.4 |

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/ngineered/nginx-php-fpm.git
docker build -t nginx-php-fpm:latest .
```

## Pulling from Docker Hub
Pull the image from docker hub rather than downloading the git repo. This prevents you having to build the image on every docker host:
```
docker pull richarvey/nginx-php-fpm:latest
```

## Running
To simply run the container:
```
sudo docker run -d richarvey/nginx-php-fpm
```

You can then browse to ```http://<DOCKER_HOST>:8080``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address.

### Volumes
If you want to link to your web site directory on the docker host to the container run:
```
sudo docker run -d -v /your_code_directory:/var/www/html richarvey/nginx-php-fpm
```

## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```

### Displaying Errors
If you want to display PHP errors on screen (in the browser) for debugging purposes use this feature:
```
-e ERRORS=1
```
