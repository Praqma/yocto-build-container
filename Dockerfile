# Base image for building Yocto images
FROM ubuntu:14.04

# Add support for proxies.
# Values should be passed as build args
# http://docs.docker.com/engine/reference/builder/#arg
ENV http_proxy ${http_proxy:-}
ENV https_proxy ${https_proxy:-}
ENV no_proxy ${no_proxy:-}

ENV DEBIAN_FRONTEND noninteractive

# Yocto's depends
# Taken from here http://www.yoctoproject.org/docs/2.1/mega-manual/mega-manual.html#packages
RUN apt-get -qq --yes update && \
    apt-get -qq --yes install gawk wget git-core diffstat unzip \
    texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev \
    xterm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# We need this because of this https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
# Here is solution https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64
RUN chmod +x /usr/local/bin/dumb-init
# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# create a group/user
RUN groupadd --gid 1000 buildgroup

# create a non-root user
RUN useradd --home-dir /var/build -s /bin/bash \
        --non-unique --uid 1000 --gid 1000 --groups sudo \
        builduser

WORKDIR /var/build

# give users in the sudo group sudo access in the container
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builduser