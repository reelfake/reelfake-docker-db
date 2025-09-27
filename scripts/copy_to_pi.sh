scp ../*.env predd@dockerpi:./reelfake-db
scp ../Dockerfile-* predd@dockerpi:./reelfake-db
scp ../docker-compose.yaml predd@dockerpi:./reelfake-db
scp -r ../data predd@dockerpi:./reelfake-db/data
scp ./init-*.sql predd@dockerpi:./reelfake-db/scripts