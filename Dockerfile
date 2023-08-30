FROM ruby:3.0.6

WORKDIR /root

# Google-chrome needs an additional repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list
RUN wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip \
    && mv chromedriver /usr/local/share/ \
    && chmod +x /usr/local/share/chromedriver \
    && ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver \
    && ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

RUN apt-get update \
    && apt-get -y install tzdata git build-essential patch ruby-dev zlib1g-dev liblzma-dev default-jre sudo google-chrome-stable vim nano tmux

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
WORKDIR /
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
