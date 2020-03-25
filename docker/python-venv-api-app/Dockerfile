FROM python:3-alpine

RUN python -m venv /opt/.venv
RUN source /opt/.venv/bin/activate
RUN pip install gunicorn flask flask_restx

COPY app.py /opt

ENTRYPOINT cd /opt; gunicorn app:app -b "0.0.0.0:8080" -w 2
