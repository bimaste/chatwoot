# Imagem base oficial do Chatwoot para Codespaces
FROM ghcr.io/chatwoot/chatwoot_codespace:latest

# Usa o usuário root para instalar dependências globais
USER root

# Habilita o corepack e ativa o Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Define o diretório de trabalho
WORKDIR /workspace

# Copia o projeto para dentro do container
COPY . /workspace

# Instala as dependências do projeto
RUN yarn && gem install bundler && bundle install
