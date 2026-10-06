# Imagem base leve com o servidor web Nginx
FROM nginx:alpine

# Incorpora a aplicação ao diretório servido pelo Nginx
COPY app/ /usr/share/nginx/html/

# O Nginx escuta na porta 80 dentro do container
EXPOSE 80
