# crypto-clock

A dashboard for cyrpto currencies intended to be shown on eink devices such as the Amazon Kindle. The project was inspired by cyrpto price tickers such as the 'block clock'. The crypto data comes from Binance's API. You can [read my article](https://medium.com/@jimmyff/crypto-clock-the-crypto-currency-ticker-that-runs-on-a-kindle-2bc601244556?source=friends_link&sk=47d142779ce7969e8ee82a9ebb770a7f) detailing the Cryto Clock project.

---

## Features

* Shows crytpo currency prices and daily change percentage
* Animates data changes like a split-flip display
* Cycles through various crypto symbols
* Settings UI to configure crypto symbols, and update frequency
* Shows clock at the top of each hour
* Clock shows sun/moon in the sky, they rise on the right (East) and set on the left (West)
* Timezone support

---

## Hosted version

You can access the Github hosted version here:

[https://jimmyff.github.io/crypto-clock/](https://jimmyff.github.io/crypto-clock/)

---

## Override timezone

You can specify a timezone that is different to your system/browsers default, to do so add it as a URI parameter. Please note that overriding the timezone incurrs a timezone data file download which is around 300kb. Example timezone overrides:

* [Europe/London](https://jimmyff.github.io/crypto-clock/?timezone=Europe/London)
* [America/New_York](https://jimmyff.github.io/crypto-clock/?timezone=America/New_York)

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
