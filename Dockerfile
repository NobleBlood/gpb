FROM perl:5.36.1

RUN mkdir /app
WORKDIR /app

COPY . .

RUN cpanm           \
	DBI             \
	DBD::Pg         \
	Mojolicious     \
	Test::Spec      \
	Test::More      \
	Test::Exception \
	Email::Valid

EXPOSE 3000
