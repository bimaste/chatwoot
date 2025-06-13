# Imagem base oficial do Chatwoot para Codespaces
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

# Usa o usuário root para instalar dependências globais
USER root

# Instala e configura o pnpm
RUN npm install -g pnpm

# Define o diretório de trabalho
WORKDIR /workspace

# Copia o projeto para dentro do container
COPY . /workspace

# Instala as dependências do projeto
RUN pnpm install && gem install bundler && bundle install
