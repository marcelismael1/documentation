FROM ubuntu:latest
RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install -y nmap proxychains iputils-ping net-tools ncat bash
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN useradd -m -d /home/pentester -G ssh pentester -s /bin/bash
RUN echo 'pentester:password' | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
