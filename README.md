# Getting started

This repository is a sample application for users following the getting started guide at https://docs.docker.com/get-started/.

The application is based on the application from the getting started tutorial at https://github.com/docker/getting-started

docker run -i -t --name falco --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro falcosecurity/falco:latest

docker run -d --name falco --privileged -v /var/run/docker.sock:/var/run/docker.sock falcosecurity/falco:latest



docker build -t todo-app .
docker run -d -p 3000:3000 todo-app

trivy image --severity HIGH,CRITICAL --format table --output trivy-image-report.txt todo-vuln:local

trivy fs --severity HIGH,CRITICAL --format table --output trivy-fs-report.txt .