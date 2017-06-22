#####  BEGIN Jenkins Base #####
FROM jenkinsci/jnlp-slave
MAINTAINER Victor Trac <victor@cloudkite.io>

ENV CLOUDSDK_CORE_DISABLE_PROMPTS 1
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

## Install docker-composee
RUN curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

## Install helm
RUN mkdir /tmp/helm                                      \
  && cd /tmp/helm                                        \
  && curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.5.0-linux-amd64.tar.gz | tar zxvf - \
  && cp /tmp/helm/linux-amd64/helm /usr/local/bin/helm   \
  && chmod +x /usr/local/bin/helm                        \
  && rm -rf /tmp/helm                                    

## Install git-crypt
RUN apt-get install -y make g++ libssl-dev                      \
  && git clone https://github.com/AGWA/git-crypt.git            \
  && cd git-crypt                                               \
  && make                                                       \
  && make install                                               \
  && cd ..                                                      \
  && rm -rf git-crypt                                           \
  && apt-get remove -y --purge make g++ libssl-dev 

## Clean up 
RUN apt-get clean -y                                            \
  && apt-get autoremove -y                                      \
  && rm -rf /var/lib/apt/lists/*
