FROM golang:1.24-trixie AS main

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN go build -o app ./main.go

EXPOSE 5500

CMD ["./app"]

