FROM python:3.11-slim AS builder

RUN mkdir -p /opt/dagster/app
RUN apt update && apt install -y git curl
COPY ./requirements.txt /opt/dagster/app/requirements

RUN pip install -r /opt/dagster/app/requirements/requirements.txt

FROM python:3.11-slim

# 复制编译阶段生成的依赖
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/dagster* /usr/local/bin
RUN mkdir -p /opt/dagster/app


COPY example_project/example_repo/* /opt/dagster/app/
COPY example_project/run_config /opt/dagster


WORKDIR /opt/dagster/app

EXPOSE 4000


CMD ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-f", "repo.py"]
