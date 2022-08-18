FROM nginx:1.12

RUN rm /etc/nginx/conf.d/default.conf

#  default conf for proxy service
COPY ./default.conf /etc/nginx/conf.d/default.conf

#ENTRYPOINT ["nginx"]
#CMD ["-g", "daemon off;"]