# ----------------------------------
# Environment: debian:buster-slim
# Minimum Panel Version: 0.7.X
# ----------------------------------
FROM golang:alpine as builder

LABEL author="Matthew Mjelde" maintainer="mjmjelde@gmail.com"

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/tribalwarshelp/cron

RUN go mod download

RUN go build -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/main .

ENV MODE=production
EXPOSE 8080

RUN apk add --no-cache tzdata
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait ./wait
RUN chmod +x ./wait

CMD ./wait && ./main