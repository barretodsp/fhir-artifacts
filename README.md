# Manual de Testes da API FHIR HCA

Este documento fornece os comandos básicos para testar os endpoints da API FHIR HCA.

## Pré-requisitos
- `curl` instalado
- Executar Arquivo makefile com comando "make all" na raiz desse repositório.
- Make fará o start de todos os componentes.
- API rodando em `http://api.local.hca:8082` ( a execução do makefile garante este requisito )
- API rodando em `http://api.local.hcb:8082` ( a execução do makefile garante este requisito )
- Cliente autorizado (código "hca")
- Cliente autorizado (código "hcb")
- Será necessário consultar o ObjectID de um registro na coleção Encounters do mongoDB após execução do makefile.
- Dados de Conexão: Host 127.0.0.1 | Porta: 27017 | username: hospital | password: hc123

---

## 1. Autenticação

### Obter token JWT (Cliente HCA)
```bash
curl -X POST http://api.local.hca:8082/api/v1/auth/token

export TOKEN_HCA=<token_hca_gerado>

```

### Obter token JWT (Cliente HCB)
```bash
curl -X POST http://api.local.hcb:8082/api/v1/auth/token

export TOKEN_HCB=<token_hcb_gerado>

```



## 2. Endpoints (Encounter, Patient e Practitioner)




### Consulta Encounter (Cliente HCA)
```bash
curl -X GET "http://api.local.hca:8082/api/v1/encounters/<ObjectID>?fields=fhirId,status,class,period" \
  -H "Authorization: Bearer $TOKEN_HCA"

```


### Consulta Encounter (Cliente HCB)
```bash
curl -X GET "http://api.local.hcb:8082/api/v1/encounters/<ObjectID>?fields=fhirId,status,class,period" \
  -H "Authorization: Bearer $TOKEN_HCB"

```

### Atualização Status Encounter (POST /review-request)
```bash

curl -X POST "http://api.local.hca:8082/api/v1/encounters/<ObjectID>/review-request" \
  -H "Authorization: Bearer $TOKEN_HCA" \
  -H "Content-Type: application/json" \
  -d '{"status": "cancelled"}'


curl -X POST "http://api.local.hcb:8082/api/v1/encounters/<ObjectID>/review-request" \
  -H "Authorization: Bearer $TOKEN_HCB" \
  -H "Content-Type: application/json" \
  -d '{"status": "cancelled"}'


```

## 2. Endpoints de Gestão

### Métricas (prometheus)
```bash
curl -X GET "http://api.local.hca:8082/api/v1/metrics"

curl -X GET "http://api.local.hcb:8082/api/v1/metrics"

```


### Documentação (swagger)
```bash
curl -X GET "http://api.local.hca:8082/api/v1/docs/index.html"

curl -X GET "http://api.local.hcb:8082/api/v1/docs/index.html"

```


### Healthcheck
```bash
curl -X GET "http://api.local.hca:8082/api/v1/health"

curl -X GET "http://api.local.hcb:8082/api/v1/health"

```