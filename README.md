# Lolka X Gentoo Overlay

Неофициальный оверлей Gentoo для установки нативного десктопного клиента **Lolka X** (`net-im/lolka-x-bin`).

Пакет использует live-ebuild (`9999`), который автоматически проверяет актуальную версию в официальном манифесте обновлений `lolka.app`, скачивает `.x86_64.rpm`, сверяет контрольную сумму `SHA512` и устанавливает приложение в `/opt/lolka-x`.

## Установка

### 1. Подключение оверлея

С помощью `eselect-repository`:

```bash
eselect repository add gentoo-lolka-x-overlay git https://github.com/larstale/gentoo-lolka-x-overlay 
emaint sync -r gentoo-lolka-x-overlay
```

### 2. Настройка Portage

Добавьте размаскировку версии `9999`, примите лицензию и отключите `network-sandbox` для этого пакета (чтобы `src_unpack` мог скачать актуальный RPM):

```bash
echo "net-im/lolka-x-bin **" >> /etc/portage/package.accept_keywords/lolka-x
echo "net-im/lolka-x-bin all-rights-reserved" >> /etc/portage/package.license/lolka-x

mkdir -p /etc/portage/env /etc/portage/package.env
echo 'FEATURES="-network-sandbox"' > /etc/portage/env/no-network-sandbox.conf
echo 'net-im/lolka-x-bin no-network-sandbox.conf' > /etc/portage/package.env/lolka-x
```

### 3. Установка пакета

```bash
emerge -av net-im/lolka-x-bin
```

## Обновление

Для проверки и установки свежей версии Lolka X достаточно пересобрать пакет:

```bash
emerge -av1 net-im/lolka-x-bin
```

