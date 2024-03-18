## from the original 'prebuild.Dockerfile'
# FROM python:3.6-slim-stretch
#
# FROM python:3.7-slim-stretch
#
# RUN pip install \
#    cryptography==2.6.1 \
#    github3.py==1.3.0 \
#    jwcrypto==0.6.0 \
#    pyjwt==1.7.1
# COPY token_getter.py app/
# COPY entrypoint.sh app/
# RUN chmod u+x app/entrypoint.sh
# WORKDIR app/
#
# CMD /app/entrypoint.sh
## above is from the original 'prebuild.Dockerfile'

## updates from option 2 source are below
FROM python:slim-bullseye
#
LABEL "org.opencontainers.image.source" = "https://github.com/rwaight/actions"
LABEL "org.opencontainers.image.url" = "https://github.com/rwaight/actions/tree/main/github/actions-app-token"
#RUN apt-get update \
#    && apt-get install gcc -y \
#    && apt-get clean
#
RUN pip install \
    cryptography \
    github3.py \
    jwcrypto \
    pyjwt

### 

COPY token_getter.py /app/
COPY entrypoint.sh /app/
RUN chmod u+x /app/entrypoint.sh
WORKDIR /app

CMD /app/entrypoint.sh
