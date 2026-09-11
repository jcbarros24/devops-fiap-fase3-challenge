# Stage 1: build
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o evaluation-service .

# Stage 2: imagem final mínima
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/evaluation-service /evaluation-service

EXPOSE 8004

ENTRYPOINT ["/evaluation-service"]
