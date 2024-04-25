FROM python:3.9

RUN apt-get update && apt-get install -y git
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN ${GITHUB_TOKEN}
RUN git clone https://${GITHUB_TOKEN}@github.com/celerofinancas/celerov2-models-watcher.git /app

WORKDIR /app

RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install

