FROM python

COPY dist/* /dist/

WORKDIR /dist

RUN python3 -m pip install otus-0.1.0-py3-none-any.whl

CMD ["gunicorn", "-b", "0.0.0.0:8000", "-t", "120", "--access-logfile", "-", "-w", "9", "otus.main.wsgi"]
