# Stage 1: Build the Go binary
FROM golang:1.23-alpine AS build

# Set necessary Go environment variables
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

# Install dependencies
RUN apk add --no-cache git

# Set work directory inside container
WORKDIR /app

# Copy go mod/sum files and download modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go app
RUN go build -o sms-gateway ./cmd/sms-gateway/main.go

# Stage 2: Run container with minimal base
FROM alpine:latest

# Set timezone and binary path
WORKDIR /app

# Copy the built binary from build stage
COPY --from=build /app/sms-gateway .

# App will listen on this port
ENV PORT=3000

# Default command
CMD ["./sms-gateway"]
