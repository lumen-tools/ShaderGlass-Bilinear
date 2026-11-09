# WinGlass – Hinweise für KI-Assistenten

WinGlass ist ein **inoffizieller Fork von ShaderGlass** (mausimus, https://github.com/mausimus/ShaderGlass), Basis v1.3.2. Der Besitzer (lumen-tools) programmiert nicht selbst. Erkläre Entscheidungen verständlich und auf Deutsch.

**Lies zuerst `FORK_CHANGES.md`.** Dort steht genau, was WinGlass gegenüber ShaderGlass anders macht, und wie eine neue ShaderGlass-Version übernommen wird.

## Was auf keinen Fall verloren gehen darf

1. **Bilinear Filter** (Processing-Menü): Flächenmittelung beim Herunterrechnen auf die Pixel Size, nur im Preprocess-Pass, Shader-Kette unverändert.
2. **Custom Pixel Size** (Input → Pixel Size → Custom...): 1.00–20.00 mit 2 Nachkommastellen, in Profilen gespeichert.
3. **Umbenennung zu WinGlass** nach den Wünschen von mausimus: kein sichtbares „ShaderGlass“ außer im Hinweis „Unofficial fork of ShaderGlass … by mausimus“, keine Links auf seine Doku, Issues oder Downloads, eigener Registry-Schlüssel `Software\WinGlass`, eigenes Icon, sein Copyright bleibt, geänderte Dateien tragen den Hinweis „Modified for WinGlass …“.

## Wichtige Regeln

- **Updates von mausimus** per `git merge` des neuen Tags übernehmen und danach die Checkliste in `FORK_CHANGES.md` vollständig abarbeiten. Neuerungen von ihm sind erwünscht, die drei Punkte oben haben Vorrang.
- **`ShaderGlass/ShaderGlass.rc` ist UTF-16 LE mit BOM und CRLF.** Nur mit passender Kodierung bearbeiten (z. B. Python `decode('utf-16')` / `encode('utf-16-le')` mit BOM `\xff\xfe`). Git zeigt sie als Binärdatei.
- **Menüpositionen:** `ShaderWindow::BuildProgramMenu()` greift per Position auf Untermenüs zu. Jeder neue Menüpunkt im Processing-Menü verschiebt die Positionen. Danach immer prüfen.
- **Kein Windows hier:** Bauen und Testen läuft über GitHub Actions. Release: `VERSION` auf `main` ändern (`.github/workflows/release.yml`). Test: Workflow *Runtime test* manuell starten (`.github/workflows/runtime-test.yml`).
- **Versionsnummer** steht zusätzlich in `ShaderGlass.rc` (Versionsinfo und Help-Menü „WinGlass vX“) und muss mit `VERSION` übereinstimmen.
- **Anonymität:** Commits nur als `lumen-tools <157735627+lumen-tools@users.noreply.github.com>`. Keine echten Namen, keine Links zu Claude-Chats in Commit-Nachrichten, Dateien oder Releases.
