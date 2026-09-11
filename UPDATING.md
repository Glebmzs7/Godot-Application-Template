# Как обновить общий код шаблона в проекте-потребителе

Эта папка (`Class/`) приходит в проект как `git subtree` из репозитория `Godot_Template`
(remote `godot-template`, ветка `template-class-export` — это ветка-срез, которая содержит
только содержимое папки `Class/` шаблона на верхнем уровне).

⚠️ **`git subtree split` не работает** для этого репозитория — падает с
`fatal: assertion failed` из-за известного бага git-subtree с пробелом в пути (`Сам проект/Class`).
Вместо него ветка-срез обновляется вручную через plumbing-команды (см. «Обновление общего
кода» ниже) — результат тот же (ветка с содержимым `Class/` в корне), просто без самого
скрипта `subtree split`.

## Разовая настройка (уже сделана в этом проекте)

```bash
git remote add godot-template <путь-или-URL-к-Godot_Template>
git fetch godot-template template-class-export
git subtree add --prefix=Class godot-template template-class-export --squash
```

## Обновление общего кода

Когда в шаблоне появились изменения или новые файлы в `Class/`:

1. В `Godot_Template`: внести правки, закоммитить как обычно на `master`, затем обновить
   ветку-срез вручную (`git subtree split` не работает, см. предупреждение выше):
   ```bash
   TREE=$(git rev-parse "HEAD:Сам проект/Class")
   NEWCOMMIT=$(git commit-tree "$TREE" -m "Class/ из Godot_Template" -p template-class-export)
   git branch -f template-class-export "$NEWCOMMIT"
   ```
   (`-p template-class-export` делает срез настоящей историей с предком — не обязательно, но
   удобно для `git log`/`blame`; без него тоже сработает, `subtree pull` на squash-режиме не
   заглядывает в родителей).
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
