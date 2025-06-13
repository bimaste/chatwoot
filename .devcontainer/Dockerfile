# Define o nome da imagem como argumento
ARG IMAGE_NAME=bimaste/chatwoot

# Imagem base oficial do Chatwoot para Codespaces
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

# Usa o usuário root para instalar dependências globais
USER root

# Instala e configura o pnpm
RUN npm install -g pnpm

# Prepara o ambiente para rbenv
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc

# Instala a versão do Ruby necessária
RUN rbenv install 3.3.3 -s && rbenv global 3.3.3

# Define o diretório de trabalho
WORKDIR /workspace

# Configura o Git para considerar o diretório /workspace como seguro
RUN git config --global --add safe.directory /workspace

# Copia o projeto para dentro do container
COPY . /workspace

# Configura pnpm para modo não-interativo
RUN echo "auto-install-peers=true" > .npmrc && \
    echo "strict-peer-dependencies=false" >> .npmrc

# Lista as versões de Ruby disponíveis (para debug)
RUN rbenv versions

# Instala as dependências (em duas etapas para isolar problemas)
RUN pnpm install --force

# Instala as dependências Ruby
SHELL ["/bin/bash", "-c"]
RUN eval "$(rbenv init -)" && \
    rbenv rehash && \
    rbenv global 3.3.3 && \
    rbenv versions && \
    gem install bundler && \
    bundle install
