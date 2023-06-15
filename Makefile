all: build test

build:
	docker-compose up -d web

test:
	docker exec -it web_gpb prove -r

fill_db:
	docker exec -it web_gpb /app/bin/fill_db.pl

stop:
	docker-compose stop

rm:
	docker-compose rm
