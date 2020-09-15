FROM ubuntu:latest

RUN apt-get -y update && \
    apt-get install -y apt-utils && \
    apt-get install -y make && \
    apt-get install -y gcc && \
    apt-get install -y flex && \
    apt-get install -y bison && \
    apt-get install -y colordiff

WORKDIR /app
COPY . /app
RUN chmod +x test_and_run.sh
RUN make clean all

ENTRYPOINT [ "./test_and_run.sh" ]
