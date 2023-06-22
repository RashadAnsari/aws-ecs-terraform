FROM golang:1.19-alpine AS build
RUN apk add --update --no-cache build-base
WORKDIR /app
COPY . .
RUN make build

FROM alpine:3.9
RUN apk add --update --no-cache bash ca-certificates libc6-compat
WORKDIR /app
ENV PATH="/app:${PATH}"
COPY --from=build /app/go-app .
CMD ["go-app"]
