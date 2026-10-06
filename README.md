# Avaliação Prática – Unidade I (DevOps): ambiente reproduzível

## Identificação da equipe
- **Disciplina:** Configuração e Manutenção de Infraestrutura de Software – DevOps (Prof. Adilson da Silva)
- **Integrante:** Wictor Melo
- **Empresa fictícia:** TechSolutions

## Objetivo
Padronizar o ambiente de uma pequena aplicação web da TechSolutions usando containers, de forma que qualquer pessoa consiga recriá-lo em outra máquina apenas com Git, Docker e Docker Compose, sem instalação manual de componentes.

## Diagnóstico do Ubuntu (Etapa 1)
Comandos executados na VM antes de iniciar a configuração:
```text

$ whoami
ubuntu


$ hostname
gerenciamento-processos


$ hostname -I | cut -d' ' -f1
192.168.252.3


$ grep PRETTY_NAME /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"


$ git --version
git version 2.43.0


$ docker --version
Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2


$ docker compose version
Docker Compose version 2.40.3+ds1-0ubuntu1~24.04.1
```

## Arquitetura
```text
 navegador ──► :8080 ──► [ app ]   Nginx servindo app/index.html (imagem construída do Dockerfile)
 navegador ──► :8081 ──► [ phpmyadmin ] ──(rede do Compose, host "mysql")──► [ mysql ]  banco "empresa"
```
Os três serviços ficam na mesma rede criada pelo Docker Compose; por isso o phpMyAdmin encontra o MySQL pelo **nome do serviço** (`mysql`), sem usar IP.

## Serviços e portas
| Serviço | Origem | Porta no host | Observação |
|---|---|---|---|
| app | `build: .` (Dockerfile, base `nginx:alpine`) | **8080** → 80 | página TechSolutions v1.0 |
| mysql | `image: mysql:8` | (não publicada) | banco `empresa`, usuário `aluno`, volume `db_data` |
| phpmyadmin | `image: phpmyadmin:latest` | **8081** → 80 | `PMA_HOST=mysql`, aguarda o MySQL ficar saudável |

Credenciais do laboratório (somente para uso local de estudo): usuário `aluno`, senha `aluno123` (usuário root: `root123`). Podem ser trocadas copiando `.env.example` para `.env` (arquivo ignorado pelo Git).

## Estrutura do projeto
```text
avaliacao-devops/
├── app/index.html
├── Dockerfile
├── .dockerignore
├── compose.yaml
├── .env.example
├── README.md
└── .gitignore
```

## Como usar
Pré-requisitos: Git, Docker e Docker Compose v2 (as portas 8080 e 8081 devem estar livres).

```bash
git clone <URL-do-repositorio> avaliacao-devops   # ou copie a pasta do projeto
cd avaliacao-devops

docker compose up -d --build     # iniciar (constrói a imagem e sobe os 3 serviços)
docker compose ps                # verificar os containers
docker compose logs -f mysql     # (opcional) acompanhar os logs de um serviço
docker compose down              # encerrar e remover os containers (mantém os dados do banco)
docker compose down -v           # encerrar removendo também o volume do banco
```
O MySQL leva de 30 a 60 segundos para ficar pronto na primeira execução; o phpMyAdmin só inicia depois disso.

### Acessar a aplicação
Abra **http://localhost:8080** (ou `http://<IP-da-VM>:8080`). A página mostra TechSolutions, Ambiente DevOps, Versão 1.0 e os integrantes.

### Acessar o phpMyAdmin
Abra **http://localhost:8081** (ou `http://<IP-da-VM>:8081`) e entre com usuário `aluno` e senha `aluno123`. O banco `empresa` aparece na lista à esquerda, comprovando a comunicação com o MySQL.

## Verificações úteis
```bash
docker compose ps
curl -I http://localhost:8080
curl -I http://localhost:8081
docker compose exec phpmyadmin getent hosts mysql        # nome do serviço resolvido
docker compose exec mysql mysql -ualuno -paluno123 -e 'SHOW DATABASES;'
```

## Teste de reprodutibilidade (Etapa 7)
```bash
docker compose down -v           # interrompe e remove containers, rede e volume
docker rmi techsolutions-app:1.0 # remove a imagem construída
docker compose ps                # nenhum serviço em execução
docker compose up -d --build     # reconstrói tudo a partir do Dockerfile e do compose.yaml
```

## Histórico Git
Repositório versionado na branch `main`; consulte com `git log --oneline`.

## Resultado do teste de reprodutibilidade
Executado em 06/10/2026 17:04 na VM Ubuntu 24.04: `docker compose down -v` e remoção da imagem deixaram zero serviços em execução; em seguida `docker compose up -d --build` reconstruiu a imagem pelo Dockerfile e recriou os três serviços, com a aplicação em :8080, o phpMyAdmin em :8081 e o banco `empresa` acessível pelo usuário `aluno`, sem nenhuma configuração manual anterior.
