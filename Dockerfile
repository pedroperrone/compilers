FROM ubuntu:latest

RUN apt-get -y update && apt-get install -y apt-utils && apt-get install -y make && apt-get install -y gcc \
    && apt-get install -y flex
COPY * .
