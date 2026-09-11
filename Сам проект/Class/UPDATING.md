# Как обновить общий код шаблона в проекте-потребителе

Эта папка (`Class/`) приходит в проект как `git subtree` из репозитория `Godot_Template`
(remote `godot-template`, ветка `template-class-export` — это ветка-срез, которая содержит
только историю папки `Class/` шаблона, полученная через `git subtree split --prefix=Class`).

## Разовая настройка (уже сделана в этом проекте)

```bash
git remote add godot-template <путь-или-URL-к-Godot_Template>
git fetch godot-template template-class-export
git subtree add --prefix=Class godot-template template-class-export --squash
```

## Обновление общего кода

Когда в шаблоне появились изменения или новые файлы в `Class/`:

1. В `Godot_Template`: внести правки, закоммитить как обычно на `master`, затем обновить
   ветку-срез:
   ```bash
   git subtree split --prefix=Class -b template-class-export-new
   git branch -f template-class-export template-class-export-new
   git branch -d template-class-export-new
   ```
2. В проекте-потребителе (этот проект, или любой другой, подключённый так же):
   ```bash
   git fetch godot-template template-class-export
   git subtree pull --prefix=Class godot-template template-class-export --squash
   ```

Новый файл, добавленный в `Class/` шаблона, подхватывается тем же `subtree pull` — отдельных
шагов не требует.

## Если нужно править общий код прямо здесь

Можно — subtree это обычные файлы, `git` не запрещает их менять. При следующем `subtree pull`
могут возникнуть обычные конфликты слияния для изменённых файлов — разрешаются как любой
`git merge`. Если правка нужна ВСЕМ проектам — лучше сначала внести её в `Godot_Template` и
подтянуть сюда через `subtree pull`, а не наоборот.

## Что НЕ входит в `Class/` (специфично для конкретного проекта)

Код, который нужен только этому проекту (игровая логика Power_struggle, экраны Life_Operator и
т.п.), не должен жить в `Class/` — иначе он потеряется/будет мешать при следующем `subtree pull`.
Держите его в соседней папке (например `GameClass/` в Power_struggle).
