FROM ruby:3.0.6

WORKDIR /root

RUN apt-get update \
    && apt-get -y install tzdata git build-essential patch ruby-dev zlib1g-dev liblzma-dev default-jre sudo vim nano tmux \
    libxkbcommon-dev libgbm-dev # Needed to run Chrome

# Container user and group
ARG USERNAME=lumen
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# Use the latest bundler version
RUN gem update --system
RUN gem update bundler

# Install and cache gems
WORKDIR /app
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

# To be able to create a .bash_history
WORKDIR /home/lumen/hist
RUN sudo chown -R $USERNAME:$USERNAME /home/lumen/hist

# Code mounted as a volume
WORKDIR /app

# Just to keep the containder running
CMD (while true; do sleep 1; done;)
