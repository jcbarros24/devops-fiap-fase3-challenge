# Stage 1: builder — instala as dependências em um venv isolado
FROM python:3.11-slim AS builder

WORKDIR /app

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: imagem final — só o interpretador + o venv pronto + o código
FROM python:3.11-slim

WORKDIR /app

RUN useradd --no-create-home --uid 1000 appuser

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY app.py .

USER appuser

EXPOSE 8005

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8005/health', timeout=2)" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8005", "--workers", "1", "app:app"]
