# vi:ft=dockerfile
FROM rockylinux/rockylinux:9

# SYSTEM
RUN yum clean all
RUN yum upgrade -y
RUN yum install -y wget which
RUN yum install -y sudo

# ENVIRONMENT
RUN yum install -y git perl ruby
RUN yum install -y perl-Data-Dumper perl-IPC-Cmd
RUN yum install -y gcc gcc-c++ make ant ant-junit maven
RUN yum install -y rpm-build createrepo zlib* rsync
RUN curl https://rclone.org/install.sh | sudo bash
# Install OpenJDK 8 and 11
RUN yum install -y java-1.8.0-openjdk-devel java-11-openjdk-devel
# Build tools
RUN yum install -y xerces-j2 xalan-j2 xml-commons-resolver xml-commons-apis ant

# Set up alternatives for Java 8
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.8.0-openjdk/bin/java 1
RUN update-alternatives --set java /usr/lib/jvm/java-1.8.0-openjdk/bin/java
RUN update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.8.0-openjdk/bin/javac 1
RUN update-alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk/bin/javac

# To enable powertools
# Check - https://wiki.rockylinux.org/rocky/repo/#notes-on-difference-between-x-and-xy-in-mirrors
# And check - https://forums.rockylinux.org/t/how-do-i-install-powertools-on-rocky-linux-9/7427
RUN sudo dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --enable crb

# USER
RUN groupadd --gid 1000 build \
    && useradd --uid 1000 --gid 1000 -m build \
    && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && chown -R 1000:1000 /home/build

USER build
WORKDIR /home/build
