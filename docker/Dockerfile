FROM node:21.7.1-bullseye-slim
RUN apt update && apt install -y git wget
WORKDIR /opt
RUN git clone https://github.com/Renovamen/oh-my-cv
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.shrc" SHELL="$(which sh)" sh -
RUN chmod +x /root/.shrc && /root/.shrc && cp /root/.local/share/pnpm/pnpm /usr/bin
RUN cd oh-my-cv && pnpm install
RUN cd oh-my-cv && pnpm build:pkg
