# Bakaláři - Webová Aplikace

Toto je kompletní kód webové aplikace. Tato webová aplikace slouží jako alternativní metoda přístupu k systému Bakaláři. Umí zobrazovat váhy předmětů, počítat průměr, zobrazovat denní rozvrh, a dokonce funguje i offline.

Tato webová aplikace je momentálně dostupná na [bakaweb.ga](https://bakaweb.ga/). Certifikát prozatím není validní, vše hostuji domu a používám sebou podepsaný certifikát.

Tato webová aplikace používá knihovnu kterou jsem napsal: [soptikha2/bakalari](https://github.com/soptikha2/bakalari).

Aplikace je napsaná v [Dartu](https://dartlang.org) a používá framework [rikulo/stream](https://github.com/rikulo/stream/).

## Logování

Tato aplikace loguje přístupy IP adres, které jsou zahashovány. Toto se používá ke kreslení grafu, který zobrazuje unikátní přístupy na den. Rovněž je logována škola a třída přihlašovaných studentů, což je ovšem plně anonymní (dokonce i bez ip adres). Toto je také používání ke kreslení grafů. Všechna ostatní data jsou v databázi zašifrována klíčem, který existuje pouze v prohlížeči uživatele - bez uživatele tyto data nejdou rozšifrovat.

## Vlastní hostování

Jestli chcete hostovat aplikaci na vlastním serveru, stačí stáhnout zdrojové kódy. Poté je nutné vygenerovat soubor, ve kterém budou uloženy důležité informace jako třeba hash administrátorského hesla.

Nejdřív je ale nutné stáhnout pár balíčků, mělo by stačit spustit příkaz `pub get` v složce tohoto projektu.

Poté spusťte soubor `generate-secret-file.dart` a plňte instrukce, které budou posílány na `stderr`. `stdout` přesměrujte do cílové lokace souboru, což je relativně `web/webapp/secret.dart`.

```
$ dart generate-secret-file.dart > web/webapp/secret.dart
```

Poté stačí spustit soubor `web/webapp/main.dart` a server se spustí na portu `8080`.

## Jak to funguje uvnitř

Ohledně fungování dotazů na server se podívejte na knihovnu [soptikha2/bakalari](https://github.com/soptikha2/bakalari).

Relativně k složce `web/webapp`:

Soubor `config.dart` definuje základní konfiguraci serveru a mapuje URI adresy na controllery. V složce `controller` jsou kontrolery pro administrátora, studenta, a poté obecné kontrolery pro jednotlivé stránky nebo věci, co se nehodí nikam jinam.

Ve složce `tools` jsou nástroje, které se starají například o ukládání hesel nebo o přístup do databáze.

Ve složce `view` jsou různé templaty. Tyto templaty končí na `.rsp.html`, jdou zkompilovat pomocí skriptu `buildRsp.sh` v rootu projektu. Po zkompilování se vytvoří soubory `.rsp.dart`, které jsou používány webserverem.

Ve složce model jsou jednotlivé objekty, se kterými webová aplikace pracuje, jako třeba student nebo zprávy zasílané administrátorovi.

## V případě nouze

Administrátor může dočasně vypnout server. Po přihlášení je v dolní části stránky formulář. Po vyplnění důvodu, který bude zobrazen všem uživatelům a znovu zadáním dvoufaktorového kódu budou všechny žádosti (včetně těch na administrátorský panel) přesměrovány na chybovou stránku. Momentálně jsou dvě, jedna prázdná (pouze s textem od administrátora) a druhá s předpřiveným obrázkem v případě nutnosti použít status [451](https://en.wikipedia.org/wiki/HTTP_451).

Administrátor může na těchto stránkách používat libovolné HTML.

Tato změna bude trvat až do manuálního restartu serveru. Může být učiněna permanentní, ale je nutné v souboru `config.dart` změnit několik hodnot (konkrétně `siteShutdownType` a `siteShutdownReason`).
