# crypto-clock

![Crypto Clock](https://github.com/jimmyff/crypto-clock/raw/master/misc/photo.jpg)

A dashboard for cyrpto currencies intended to be shown on eink devices such as the Amazon Kindle. The project was inspired by cyrpto price tickers such as the 'block clock'. The crypto data comes from Binance's API. You can [read my write up](https://medium.com/@jimmyff/crypto-clock-the-crypto-currency-ticker-that-runs-on-a-kindle-2bc601244556?source=friends_link&sk=47d142779ce7969e8ee82a9ebb770a7f) detailing the project and watch a [quick video](https://www.youtube.com/watch?v=qPAcM4U1mio) demonstrating the Cyrpto Clock.

---

## Features

* Shows crytpo currency prices and daily change percentage
* Animates displays changes like retro split-flip displays
* Cycles through various crypto currency symbol pairs
* Configuration UI to choose crypto symbol pairs and update frequencies
* Shows clock at the top of each hour
* Clock shows sun/moon in the sky, they rise on the left and set on the right
* Timezone override support

---

## Hosted version

Dedicated device (eg: Kindle) version:

[https://jimmyff.github.io/crypto-clock/](https://jimmyff.github.io/crypto-clock/)

Desktop/mobile version:

[https://jimmyff.github.io/crypto-clock/desktop.html](https://jimmyff.github.io/crypto-clock/desktop.html)

---

## Override timezone

You can specify a timezone that is different to your system/browsers default by adding it as a URI parameter. Please note that overriding the timezone incurs a timezone data file download which is around 300kb. Example timezone overrides:

* [Europe/London](https://jimmyff.github.io/crypto-clock/?timezone=Europe/London)
* [America/New_York](https://jimmyff.github.io/crypto-clock/?timezone=America/New_York)

---

## Development

This is a Dart web app that compiles to Javascript. To run the Dart app locally use build_runner serve:

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
