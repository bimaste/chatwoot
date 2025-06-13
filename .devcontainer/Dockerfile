# Imagem base oficial do Chatwoot para Codespaces
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

# Usa o usuário root para instalar dependências globais
USER root

# Instala e configura o pnpm
RUN npm install -g pnpm

# Instala a versão do Ruby necessária
RUN rbenv install 3.3.3 -s && rbenv global 3.3.3

# Define o diretório de trabalho
WORKDIR /workspace

# Copia o projeto para dentro do container
COPY . /workspace

# Configura pnpm para modo não-interativo
RUN echo "auto-install-peers=true" > .npmrc && \
    echo "strict-peer-dependencies=false" >> .npmrc

# Instala as dependências do projeto (com flags para evitar prompts interativos)
RUN pnpm install --force && \
    gem install bundler && \
    bundle install
