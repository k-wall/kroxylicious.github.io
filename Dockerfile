FROM ubuntu:24.04

ENV JEKYLL_SERVE_BIND=127.0.0.1

RUN apt-get update && \
    apt install -y git \
                   curl \
                   build-essential \
                   libssl-dev \
                   libreadline-dev \
                   zlib1g-dev \
                   libffi-dev \
                   libyaml-dev \
                   libncurses5-dev \
                   libgdbm-dev \
                   unzip \
                   wget \
                   golang && \
                   rm -rf /var/lib/apt/lists/*
ENV RBENV_ROOT /usr/local/rbenv
RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} && \
    git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build

ENV PATH="${RBENV_ROOT}/bin:${PATH}"
RUN eval "$(rbenv init -)" && \
    rbenv install 3.4.4 && \
    rbenv global 3.4.4 && \
    gem install bundler && \
    go install github.com/asciitosvg/asciitosvg/cmd/a2s@latest && \
    mv /root/go/bin/a2s /usr/local/bin/ && \
    chmod 777 /usr/local/bin/a2s

COPY Gemfile .
COPY Gemfile.lock .
RUN eval "$(rbenv init -)" && \
    bundle install

RUN mkdir /css/
WORKDIR /css/
COPY _sass .
COPY bootstrap_setup.sh .
RUN ./bootstrap_setup.sh

RUN mkdir /site/
WORKDIR /site/
EXPOSE 4000
# Note --incremental mode is ineffective on the Mac owing to https://github.com/containers/podman/issues/22343.  Use force_regenerate.sh to trigger the incremental reload after changing the file on the host.
CMD eval "$(rbenv init -)" && cp -r /css/_sass/bootstrap /site/_sass/ && bundle exec jekyll serve --host ${JEKYLL_SERVE_BIND} --incremental --disable-disk-cache --destination /tmp/site
