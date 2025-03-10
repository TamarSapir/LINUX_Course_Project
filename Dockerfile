FROM python:3

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt
COPY . /app

WORKDIR /app/Work/Q2

CMD ["python", "plant.py"]
