# LuizaLabs - Desafio técnico

API REST construída em **Ruby**, com foco em **simplicidade**, **lógica**, **testes automatizados** e aplicação de princípios **SOLID**.  
Responsável por processar arquivos legados de pedidos desnormalizados, persistir os dados e disponibilizá-los através de uma API.

---

##  Tecnologias e padrões utilizados

- **Linguagem:** Ruby
- **Framework:** Ruby on Rails (API-only mode)
- **Banco de dados:** PostgreSQL (local)
- **Testes:** RSpec
- **Arquitetura:** Service Objects, Controllers, Models
- **Estilo de código:** Padrões SOLID aplicados na modelagem e nos serviços

---

##  Objetivo do projeto

O sistema lê arquivos `.txt` com pedidos desnormalizados, extrai e normaliza os dados, e permite consultá-los por meio de uma API.  
Os dados são agrupados por usuário e filtráveis por:

- `order_id`
- `start_date`
- `end_date`

---

##  Como rodar o projeto

### 1. Requisitos

- Ruby >= 3.0
- Rails >= 7
- PostgreSQL
- Bundler (`gem install bundler`)

### 2. Instalação

Clone o repositório e instale as dependências:

```bash
git clone https://github.com/echoPacheco/luiza-labs.git
cd luiza-labs
bundle install
```
### 3. Configuração do banco
Crie um arquivo `.env` com suas credenciais do PostgreSQL local:
```bash
DB_USERNAME=username
DB_PASSWORD=password
```
Crie e migre o banco:
```bash
rails db:create db:migrate
```

### 4. Subir o servidor
```bash
rails server
```
Acesse em: http://localhost:3000

---
### Endpoints disponíveis
**POST** `/api/orders/upload`

Faz upload de um arquivo `.txt` contendo os pedidos.
Formato esperado: cada linha representa um item de um pedido (desnormalizado).

Exemplo:
```bash
curl -X POST -F "file=@data_1.txt" http://localhost:3000/api/orders/upload
```

Resposta:
```json
{  "message": "Order file processed successfully"  }
```

**GET** `/api/orders`

Retorna os pedidos agrupados por usuário.
Filtros disponíveis via query params:

- `order_id=123`

- `start_date=YYYY-MM-DD`

- `end_date=YYYY-MM-DD`

Exemplo:

```bash
curl "http://localhost:3000/api/orders?start_date=2024-01-01&end_date=2024-12-31"
```

### Rodar os testes
```bash
bundle exec rspec
```

Os testes cobrem:

- Upload e processamento de arquivos

- Retorno da API com e sem filtros

- Estrutura e integridade dos dados persistidos