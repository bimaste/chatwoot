# Imagem base oficial do Chatwoot para Codespaces
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

# Usa o usuário root para instalar dependências globais
USER root

# Instala e configura o pnpm
RUN npm install -g pnpm

# Instala a versão do Ruby necessária e configura o rbenv
RUN rbenv install 3.3.3 -s && \
    rbenv global 3.3.3 && \
    echo 'eval "$(rbenv init -)"' >> /root/.bashrc

# Define o diretório de trabalho
WORKDIR /workspace

# Configura o Git para considerar o diretório /workspace como seguro
RUN git config --global --add safe.directory /workspace

# Copia o projeto para dentro do container
COPY . /workspace

# Configura pnpm para modo não-interativo
RUN echo "auto-install-peers=true" > .npmrc && \
    echo "strict-peer-dependencies=false" >> .npmrc

# Carrega o rbenv e instala as dependências
SHELL ["/bin/bash", "-c"]
RUN source /root/.bashrc && \
    pnpm install --force && \
    gem install bundler && \
    bundle install
