FROM example.repo.com/cache/chainguard/python:current AS build

USER root

WORKDIR /application
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

USER nonroot

EXPOSE 8501
EXPOSE 80

ENTRYPOINT ["streamlit", "run", "/application/application.py", "--server.address=0.0.0.0", "--server.headless=true"]
