FROM python:3.7.13-alpine3.16
COPY . ./

RUN apk add --update --no-cache postgresql-client jpeg-dev
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev

#RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
#RUN python3 -m ensurepip
#RUN pip3 install --no-cache --upgrade pip setuptools

RUN pip install --no-cache --upgrade pip \
    pip install pyproject-toml \
    pip install -r requirements.txt

ENTRYPOINT FLASK_APP=app.py flask run --host=0.0.0.0
#CMD ["uwsgi", "app.ini"]
#CMD FLASK_APP=./app.py flask run --host 0.0.0.0
