FROM ubuntu:latest
RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install -y nmap proxychains iputils-ping net-tools ncat bash python3 python3-pip
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN useradd -m -d /home/pentester -G ssh pentester -s /bin/bash
RUN echo 'pentester:password' | chpasswd
COPY . /opt 
RUN pip3 install -r /opt/requirements.txt

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
