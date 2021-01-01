FROM golang:1.15-alpine as builder


RUN apk add --no-cache \
        gcc \
        git \
        make \
        musl-dev

WORKDIR /src
COPY . .

RUN GOBIN=/app \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    go install \
        -ldflags "-s -w \
            -X 'github.com/prometheus/common/version.Version=$(git describe --tags --abbrev=0 --match="[0-9]*")' \
            -X 'github.com/prometheus/common/version.Revision=$(git rev-parse --short HEAD)' \
            -X 'github.com/prometheus/common/version.Branch=$(git symbolic-ref -q --short HEAD)' \
            -X 'github.com/prometheus/common/version.BuildUser=$(git config --get user.email)' \
            -X 'github.com/prometheus/common/version.BuildDate=$(date -u "+%Y-%m-%dT%H:%M:%S%z")' \
            -linkmode external -extldflags -static" \
        . \
    && chmod 755 /app/mikrotik-exporter


FROM scratch

COPY --from=builder /app/mikrotik-exporter /bin/mikrotik-exporter

EXPOSE 9436

CMD ["mikrotik-exporter"]
