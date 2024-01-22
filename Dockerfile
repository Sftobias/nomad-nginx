FROM nginx
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
CMD /bin/bash -c "nginx -g 'daemon off;' & sleep 5000 && kill -9 0 && echo 'killed'"