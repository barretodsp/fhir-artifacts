FROM python:3.11-slim

RUN pip install ansible docker docker-compose

WORKDIR /playbook
COPY playbook.yml /playbook/
COPY inventories /playbook/inventories

CMD ["ansible-playbook", "-i", "inventories/local.yml", "playbook.yml"]
