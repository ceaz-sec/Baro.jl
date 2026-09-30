```baro_banner()
```

---
**Package**: litellm  | 2026-09-30T17:28:22.311

## Ownship Contact, License, Version and Dependencies.

**Package Summary**
- Library to easily interface with LLM API providers

**Author**
- BerriAI

**License Expression**
- MIT...

**Version**
- 1.103.1

**Public Repository**
- https://litellm.ai

**Yanked Status**
- false 

---

**SHA256**
- 78d92d1e268fa23410a612fabe3970863b78efb9582c24a503a19d84aeed5155

**Release**
- litellm-1.103.1-cp310-abi3-macosx_10_12_x86_64.whl

> Requires Python Version: <3.15,>=3.10

> Dependencies (102): ["fastuuid<1.0,>=0.14.0", "httpx[http2]<1.0,>=0.28.0", "openai<3.0.0,>=2.20.0", "python-dotenv<2.0,>=1.0.0", "tiktoken<1.0,>=0.8.0; python_full_version < \"3.14\"", "tiktoken<1.0,>=0.12.0; python_full_version >= \"3.14\"", "importlib-metadata<9.0,>=8.0.0", "tokenizers<1.0,>=0.21.0", "click<9.0,>=8.0.0", "jinja2<4.0,>=3.1.6", "aiohttp<4.0,>=3.14.2", "pydantic<3.0.0,>=2.11.0; python_full_version < \"3.14\"", "pydantic<3.0.0,>=2.12.0; python_full_version >= \"3.14\"", "pydantic-settings<3.0,>=2.14.1", "jsonschema<5.0,>=4.0.0", "boto3<2.0,>=1.43.1", "gunicorn<24.0,>=23.0.0; extra == \"proxy\"", "uvicorn<1.0,>=0.33.0; extra == \"proxy\"", "granian<3.0,>=2.7.4; extra == \"proxy\"", "uvloop<1.0,>=0.22.1; sys_platform != \"win32\" and extra == \"proxy\"", "fastapi<1.0,>=0.136.3; extra == \"proxy\"", "starlette<2.0,>=1.0.1; extra == \"proxy\"", "backoff<3.0,>=2.2.1; extra == \"proxy\"", "pyyaml<7.0,>=6.0.3; extra == \"proxy\"", "rq<3.0,>=2.7.0; extra == \"proxy\"", "orjson<4.0,>=3.11.6; extra == \"proxy\"", "hiredis<4.0,>=3.0.0; extra == \"proxy\"", "apscheduler<4.0,>=3.11.2; extra == \"proxy\"", "fastapi-sso<1.0,>=0.19.0; extra == \"proxy\"", "pyjwt<3.0,>=2.13.0; extra == \"proxy\"", "python-multipart<1.0,>=0.0.27; extra == \"proxy\"", "cryptography<51.0,>=49.0.0; extra == \"proxy\"", "pynacl<2.0,>=1.6.2; extra == \"proxy\"", "websockets<16.0,>=15.0.1; extra == \"proxy\"", "boto3<2.0,>=1.43.1; extra == \"proxy\"", "azure-identity<2.0,>=1.25.2; extra == \"proxy\"", "azure-storage-blob<13.0,>=12.28.0; extra == \"proxy\"", "mcp<3,>=2.2.0; extra == \"proxy\"", "httpx2<3,>=2.5.0; extra == \"proxy\"", "pydantic<3,>=2.12.0; extra == \"proxy\"", "litellm-proxy-extras==0.4.100; extra == \"proxy\"", "litellm-enterprise==0.1.69; extra == \"proxy\"", "restrictedpython<9.0,>=8.5; extra == \"proxy\"", "rich<14.0,>=13.9.4; extra == \"proxy\"", "inquirerpy<1.0,>=0.3.4; extra == \"proxy\"", "tomlkit<1.0,>=0.13.3; extra == \"proxy\"", "polars<2.0,>=1.38.1; extra == \"proxy\"", "soundfile<1.0,>=0.12.1; extra == \"proxy\"", "pyroscope-io<1.0,>=0.8.16; sys_platform != \"win32\" and extra == \"proxy\"", "expression<6.0,>=5.6.0; extra == \"proxy\"", "rich<14.0,>=13.9.4; extra == \"cli\"", "pyyaml<7.0,>=6.0.3; extra == \"cli\"", "requests<3.0,>=2.32.0; extra == \"cli\"", "inquirerpy<1.0,>=0.3.4; extra == \"cli\"", "keyring<26.0,>=25.6.0; extra == \"cli\"", "tomlkit<1.0,>=0.13.3; extra == \"cli\"", "prisma<1.0,>=0.11.0; extra == \"extra-proxy\"", "psycopg<4.0,>=3.2; extra == \"extra-proxy\"", "psycopg-binary<4.0,>=3.2; extra == \"extra-proxy\"", "azure-identity<2.0,>=1.25.2; extra == \"extra-proxy\"", "azure-keyvault-secrets<5.0,>=4.10.0; extra == \"extra-proxy\"", "google-cloud-kms<3.0,>=2.24.2; extra == \"extra-proxy\"", "google-cloud-iam<3.0,>=2.19.1; extra == \"extra-proxy\"", "resend<3.0,>=2.23.0; extra == \"extra-proxy\"", "redisvl<1.0,>=0.4.1; extra == \"extra-proxy\"", "a2a-sdk<2.0,>=1.1.0; extra == \"extra-proxy\"", "numpydoc<2.0,>=1.8.0; extra == \"utils\"", "diskcache<6.0,>=5.6.3; extra == \"caching\"", "mcp<3,>=2.2.0; extra == \"mcp\"", "httpx2<3,>=2.5.0; extra == \"mcp\"", "pydantic<3,>=2.12.0; extra == \"mcp\"", "python3-saml<2.0,>=1.16.0; extra == \"saml\"", "semantic-router<1.0,>=0.1.15; python_full_version < \"3.14\" and extra == \"semantic-router\"", "aurelio-sdk<1.0,>=0.0.19; python_full_version < \"3.14\" and extra == \"semantic-router\"", "mlflow<4.0,>=3.11.1; extra == \"mlflow\"", "grpcio==1.78.0; extra == \"grpc\"", "google-cloud-speech<3.0,>=2.40.0; extra == \"stt-vertex-chirp\"", "nvidia-riva-client>=2.15.0; extra == \"stt-nvidia-riva\"", "soundfile>=0.12.1; extra == \"stt-nvidia-riva\"", "audioread>=3.0.1; extra == \"stt-nvidia-riva\"", "numpy>=1.26.0; extra == \"stt-nvidia-riva\"", "google-cloud-aiplatform<2.0,>=1.133.0; extra == \"google\"", "aws-sdk-bedrock-runtime[awscrt]<0.12.0,>=0.10.0; python_full_version >= \"3.12\" and extra == \"bedrock-realtime\"", "google-cloud-aiplatform<2.0,>=1.133.0; extra == \"proxy-runtime\"", "google-cloud-speech<3.0,>=2.40.0; extra == \"proxy-runtime\"", "google-genai<2.0,>=1.37.0; extra == \"proxy-runtime\"", "anthropic[vertex]<1.0,>=0.84.0; extra == \"proxy-runtime\"", "grpcio==1.78.0; extra == \"proxy-runtime\"", "prometheus-client<1.0,>=0.20.0; extra == \"proxy-runtime\"", "langfuse<3.0,>=2.59.7; extra == \"proxy-runtime\"", "opentelemetry-api==1.28.0; extra == \"proxy-runtime\"", "opentelemetry-sdk==1.28.0; extra == \"proxy-runtime\"", "opentelemetry-exporter-otlp==1.28.0; extra == \"proxy-runtime\"", "opentelemetry-instrumentation-fastapi==0.49b0; extra == \"proxy-runtime\"", "ddtrace<5.0,>=4.8.2; extra == \"proxy-runtime\"", "sentry-sdk<3.0,>=2.21.0; extra == \"proxy-runtime\"", "mangum<1.0,>=0.17.0; extra == \"proxy-runtime\"", "azure-ai-contentsafety<2.0,>=1.0.0; extra == \"proxy-runtime\"", "azure-storage-file-datalake<13.0,>=12.20.0; extra == \"proxy-runtime\"", "pypdf<7.0,>=6.16.1; extra == \"proxy-runtime\"", "llm-sandbox<1.0,>=0.3.39; extra == \"proxy-runtime\"", "detect-secrets<2.0,>=1.5.0; extra == \"proxy-runtime\""]

