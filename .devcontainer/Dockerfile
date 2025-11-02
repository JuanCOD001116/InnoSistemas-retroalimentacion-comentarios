FROM openjdk:21-jdk-slim

# Instalar dependencias necesarias (sin instalar Docker aquí; usar la feature docker-in-docker)
RUN apt-get -y update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    postgresql-client \
    git \
    maven \
    sudo \
    curl \
    gnupg \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Configurar el repositorio de Docker
#RUN mkdir -p /etc/apt/keyrings \
#   && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
#   && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list \
#   && apt-get -y update

# Instalar Docker y sus componentes
#RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
#    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Crear el usuario developer con permisos adecuados
RUN useradd -ms /bin/bash developer \
    && mkdir -p /workspace \
    && chown -R developer:developer /workspace \
    && usermod -aG sudo developer \
    #    && usermod -aG docker developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Establecer el usuario developer como predeterminado
USER developer

# Establecer el directorio de trabajo
WORKDIR /workspace