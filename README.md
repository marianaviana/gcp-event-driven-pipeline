
## Tecnologias Utilizadas

* **Linguagem:** Python 3.11 (Google Functions Framework, SDKs `google-cloud-storage` e `google-cloud-bigquery`).
* **Infraestrutura como Código (IaC):** Terraform 1.5+.
* **Serviços GCP Declarados:**
  * **Cloud Storage (GCS):** Armazenamento de arquivos de entrada e processados.
  * **BigQuery:** Data Warehouse para consulta analítica dos dados ingeridos.
  * **Eventarc & IAM:** Disparo de eventos e gestão de identidades/acessos com privilégio mínimo.
* **Ambiente Local:** Docker, WSL (Windows Subsystem for Linux) e Git.

---

## Execução Local

### Pré-requisitos
* **Docker** e **Docker Compose** instalados.
* **Python 3.11+** configurado.

### 1. Clonar o Repositório
```bash
git clone [https://github.com/marianaviana/gcp-event-driven-pipeline.git](https://github.com/marianaviana/gcp-event-driven-pipeline.git)
cd gcp-event-driven-pipeline

```

### 2. Rodar a Aplicação em Container

```bash
docker-compose up --build

```

A aplicação estará disponível em `http://localhost:8080`.

---

## Provisionamento de Infraestrutura (Terraform)

Para aplicar a infraestrutura em um ambiente GCP real:

1. Autentique-se no GCP CLI:
```bash
gcloud auth application-default login

```


2. Inicialize e aplique o plano no diretório `terraform/`:
```bash
cd terraform
terraform init
terraform plan
terraform apply

```



---

## Exemplo de Payload (`sample-data/input_example.json`)

```json
[
  {
    "id": "evt-001",
    "timestamp": "2026-09-17T14:00:00Z",
    "payload": "Ingestão de teste serverless",
    "status": "PROCESSED"
  }
]

```

---

## Autoria

Desenvolvido por **Mariana Viana**

* GitHub: [@marianaviana](https://github.com/marianaviana)
* Projetos de Engenharia de Dados & Cloud Infrastructure

```

```
