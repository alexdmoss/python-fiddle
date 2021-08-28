# TODO: try with gcr.io/distroless/python3-debian10
# TODO: consider alpine version

FROM python:3.9.5-slim as base
# these envvars are inherited
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"
RUN groupadd -r py-app
RUN useradd -m -g py-app py-app

FROM base as builder
RUN apt-get update && apt-get install --no-install-recommends -y curl build-essential
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./
RUN poetry install --no-dev

FROM base as test
COPY --from=builder $PYSETUP_PATH $PYSETUP_PATH
COPY --from=builder $POETRY_HOME $POETRY_HOME
COPY poetry.lock pyproject.toml ./
RUN poetry install
COPY . /app/
WORKDIR /app
RUN /.venv/bin/pytest

FROM base as runtime
COPY --from=builder $PYSETUP_PATH $PYSETUP_PATH
COPY --from=test /app /app/
USER py-app
WORKDIR /app
CMD ["python", "-m", "fiddle"]
LABEL name={NAME}
LABEL version={VERSION}
LABEL maintainer={MAINTAINER}
