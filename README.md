# crypto-clock

A dashboard for cyrpto currencies intended to be shown on eink devices such as the Amazon Kindle. The project was inspired by cyrpto price tickers such as the "block clock". The crypto data comes from Binance's API.

---

## Features

* Shows crytpo currency prices and daily change percentage
* Animates data changes like a split-flip display
* Cycles through various crypto symbols
* Settings UI to configure crypto symbols, and update frequency
* Shows clock at the top of each hour
* Clock shows sun/moon in the sky, they rise on the left and set on the right

---

## Hosted version

You can access the Github hosted version here:

[https://jimmyff.github.io/crypto-clock/](https://jimmyff.github.io/crypto-clock/)

---

## Development

The is a simple Dart web app that is compiles to Javascript. To run the Dart app locally in development mode use build_runner:

```bash
dart run build_runner serve
```

To get a release ready for deployment:

```bash
mkdir build
cp web/* build/
dart run build_runner build
cp .dart_tool/build/generated/crypto_clock/web/main.dart.js build/
```
