#####  BEGIN Jenkins Base #####
FROM jenkins/jnlp-slave
MAINTAINER Victor Trac <victor@cloudkite.io>

ENV CLOUDSDK_CORE_DISABLE_PROMPTS 1
ENV DOCKER_COMPOSE_VERSION 1.23.2
ENV HELM_VERSION 2.12.2
ENV YQ_VERSION 2.2.1
ENV PATH /opt/google-cloud-sdk/bin:$PATH

USER root

RUN apt-get update -y                                    \
  && apt-get install -y jq                               \
  && curl https://sdk.cloud.google.com | bash            \
  && mv google-cloud-sdk /opt                            \
  && gcloud components install kubectl                   
##### END Jenkins Base #####

## Install aws cli
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py \
  && pip install awscli --upgrade 

## Install Docker
RUN apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable" \
    && apt-get update \
    && apt-get -y install docker-ce

## Install docker-composee
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

## Install helm
RUN mkdir /tmp/helm                                      \
  && cd /tmp/helm                                        \
  && curl -s https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar zxvf - \
  && cp /tmp/helm/linux-amd64/helm /usr/local/bin/helm   \
  && chmod +x /usr/local/bin/helm                        \
  && rm -rf /tmp/helm                                    

## Install git-crypt
RUN apt-get install -y make g++ libssl-dev                      \
  && git clone https://github.com/victortrac/git-crypt.git      \
  && cd git-crypt                                               \
  && make                                                       \
  && make install                                               \
  && cd ..                                                      \
  && rm -rf git-crypt                                           \
  && apt-get remove -y --purge make g++ libssl-dev 

## Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 > /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

## Install misc utilities
RUN apt-get install -y \
    dnsutils \
    maven && \
    tidy && \
  apt-get clean -y && \ 
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*
