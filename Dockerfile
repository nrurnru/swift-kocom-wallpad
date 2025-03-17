FROM swift:6.0-noble AS builder

WORKDIR /app

COPY Package.swift Package.resolved ./

RUN swift package resolve

COPY . .

RUN swift build -c release --static-swift-stdlib

FROM ubuntu:24.04 AS runtime

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libxml2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/.build/release/KocomSwift /app/KocomSwift

CMD ["/app/KocomSwift"]
