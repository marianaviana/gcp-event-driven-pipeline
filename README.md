# GCP Event-Driven Data Pipeline

![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

Pipeline serverless orientado a eventos criado para o **Google Cloud Platform (GCP)**. O projeto automatiza a ingestão de arquivos JSON carregados no Cloud Storage, processa os dados via Cloud Run/Functions Framework em Python, carrega-os no BigQuery e move os arquivos originais para um bucket de histórico/processados.

Toda a infraestrutura é provisionada como código (**IaC**) utilizando **Terraform**, seguindo boas práticas de arquitetura na nuvem, segurança (IAM com menor privilégio) e testes locais via **Docker**.

---

## 🏗️ Arquitetura da Solução

```text
[ User Upload ]
       │
       ▼
[ Cloud Storage ] ──(Object Finalized Event)──► [ Eventarc Trigger ]
 (Input Bucket)                                          │
                                                         ▼
                                               [ Cloud Run / Function ]
                                                 (Python Processing)
                                                         │
                                        ┌────────────────┴────────────────┐
                                        ▼                                 ▼
                               [ BigQuery Table ]              [ Cloud Storage ]
                               (Data Ingestion)               (Processed Bucket)
```

### Fluxo de Dados:
1. **Trigger de Entrada:** Um arquivo JSON contendo eventos ou transações é enviado para o bucket de entrada (`-input`).
2. **Roteamento de Evento:** O **Eventarc** captura o evento `google.cloud.storage.object.v1.finalized` de forma assíncrona.
3. **Processamento Serverless:** A aplicação em **Python** (subida via Cloud Run) faz o download do arquivo, valida e parseia a estrutura dos dados.
4. **Carga e Armazenamento:**
   * Os registros validados são inseridos estruturadamente na tabela do **BigQuery**.
   * O arquivo original é movido para o bucket de arquivos processados (`-processed`) para arquivamento auditável.

---

## 📁 Estrutura do Repositório

```text
gcp-event-driven-pipeline/
├── src/
│   ├── main.py              # Código Python da função serverless
│   ├── requirements.txt      # Dependências da aplicação
│   └── Dockerfile            # Containerização para testes e deploy
├── terraform/
│   ├── main.tf              # Declaração dos recursos GCP (Storage, BigQuery, IAM, Eventarc)
│   ├── variables.tf         # Variáveis do ambiente Terraform
│   └── outputs.tf           # Saídas e identificadores dos recursos
├── sample-data/
│   └── input_example.json   # Modelo de payload para testes
├── docker-compose.yml       # Execução local da aplicação
├── .gitignore               # Proteção contra envio de chaves/arquivos temporários
└── README.md                # Documentação técnica
```

---

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** Python 3.11 (Google Functions Framework, SDKs `google-cloud-storage` e `google-cloud-bigquery`).
* **Infraestrutura como Código (IaC):** Terraform 1.5+.
* **Serviços GCP Declarados:**
  * **Cloud Storage (GCS):** Armazenamento de arquivos de entrada e processados.
  * **BigQuery:** Data Warehouse para consulta analítica dos dados ingeridos.
  * **Eventarc & IAM:** Disparo de eventos e gestão de identidades/acessos com privilégio mínimo.
* **Ambiente Local:** Docker, WSL (Windows Subsystem for Linux) e Git.

---

## 💻 Como Executar Localmente

### Pré-requisitos
* **Docker** e **Docker Compose** instalados.
* **Python 3.11+** configurado.

### 1. Clonar o Repositório
```bash
git clone https://github.com/marianaviana/gcp-event-driven-pipeline.git
cd gcp-event-driven-pipeline
```

### 2. Rodar a Aplicação em Container
```bash
docker-compose up --build
```
A aplicação estará disponível em `http://localhost:8080`.

---

## 🏛️ Provisionamento de Infraestrutura (Terraform)

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

## 📝 Exemplo de Payload (`sample-data/input_example.json`)

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

## ✒️ Autora

Desenvolvido por **Mariana Viana**  
* GitHub: [@marianaviana](https://github.com/marianaviana)
* Projetos de Engenharia de Dados & Cloud Infrastructure