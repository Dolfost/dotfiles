# Navidrome - музика

**Адреса:** <https://navidrome.faun-castor.ts.net>

Navidrome стрімить музичну колекцію з daorus. Веб-інтерфейс є з коробки,
але головна сила - сумісність із **Subsonic API**: до нього підключається
купа гарних музичних застосунків.

## Вхід

Акаунт створює адміністратор. У браузері - просто логін і пароль на
адресі вище.

У Subsonic-клієнтах при додаванні сервера вказуй:

- **Сервер:** `https://navidrome.faun-castor.ts.net`
- **Користувач / пароль:** ті самі, що для веба

Пароль у Subsonic-клієнтах передається токеном, а весь трафік і так іде
через tailnet - тож це безпечно.

## Чим слухати

Якщо коротко: на десктопі бери **Feishin**, на Android - **Symfonium**.
Це перевірені й найкращі клієнти для цього сервера.

| Платформа | Рекомендовано | Примітки |
|---|---|---|
| Android | [Symfonium](https://play.google.com/store/apps/details?id=app.symfonik.music.player) | платний, але найкращий; безкоштовна альтернатива - [Tempo](https://f-droid.org/packages/com.cappielloantonio.notquitemy.tempo/) |
| Windows / macOS / Linux | [Feishin](https://github.com/jeffvli/feishin) | чудовий десктопний клієнт; альтернатива - [Supersonic](https://github.com/dweymouth/supersonic) |
| iOS | [play:Sub](https://apps.apple.com/us/app/play-sub-music-streamer/id955329386) або [substreamer](https://apps.apple.com/us/app/substreamer/id1012991665) | |
| Браузер | вбудований веб-плеєр | плейлисти, черга, все є |

Повний список сумісних клієнтів для всіх платформ є на
[сайті Navidrome](https://www.navidrome.org/apps/).

## Поради

- Скробблінг, плейлисти та "улюблене" синхронізуються між усіма
  клієнтами - вони живуть на сервері.
- В Symfonium/Tempo увімкни офлайн-кеш улюблених альбомів - і музика
  працює навіть без інтернету.
