FROM jenkins/jenkins:lts

USER root

ENV KUBECTL_VERSION=v1.33.3

RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN apt-get update && \
    apt-get install -y docker.io sudo && \
    usermod -aG docker jenkins

