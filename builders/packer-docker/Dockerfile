# consider reviewing the official Packer Dockerfile to see if this can be improved in the future
# link to official Dockerfile: https://github.com/hashicorp/packer/blob/main/Dockerfile
# example actions Dockerfile: https://github.com/actions/hello-world-docker-action/blob/main/Dockerfile
# another example: https://github.com/Contrast-Security-OSS/ansible-packer-docker/blob/master/Dockerfile

FROM hashicorp/packer:1.10.0

LABEL "com.github.actions.name" = "Packer build"
LABEL "com.github.actions.description" = "Run packer build on a template file"
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="blue"

LABEL "repository" = "https://github.com/rwaight/actions"
LABEL "homepage" = "https://github.com/rwaight/actions"
#LABEL "maintainer" = "Robert Anderson <riznob@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
