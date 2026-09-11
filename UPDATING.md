# Как обновить общий код шаблона в проекте-потребителе

Эта папка (`Godot_Template/`) приходит в проект как `git subtree` из репозитория `Godot_Template`
(remote `godot-template`). Полную политику веток (что такое `Стабильные`/`Бета`/`alpha/*`) см. в
`BRANCHES.md` в корне репозитория шаблона — здесь только команды для потребителя.

⚠️ **`git subtree split` и `git subtree push` не работают, если путь до папки у вас содержит
пробел** (например `Сам проект/Godot_Template`, как в Life_Operator) — падает с
`fatal: assertion failed`, известный баг git-subtree. Если у вас путь без пробела (например
просто `Godot_Template`, как в Power_struggle) — обычный `git subtree push` работает нормально,
это ограничение только `split`. Если путь с пробелом — используйте ручной вариант через
plumbing-команды (см. «Отправить правки обратно» ниже) и для `split` (см. «Обновление общего
кода»), и для push.

## Разовая настройка (уже сделана в этом проекте)

```bash
git remote add godot-template <путь-или-URL-к-Godot_Template>
git fetch godot-template export/Стабильные
git subtree add --prefix=Godot_Template godot-template export/Стабильные --squash
```

## Обновление общего кода (подтянуть новое из шаблона)

По умолчанию тянем `export/Стабильные` — то, что уже прошло обкатку в `Бета`. Если нужен ранний
доступ к тому, что ещё обкатывается — `export/Бета` вместо `export/Стабильные` везде ниже.

```bash
git fetch godot-template export/Стабильные
git subtree pull --prefix=Godot_Template godot-template export/Стабильные --squash
```

Новый файл, добавленный в `Godot_Template/` шаблона, подхватывается тем же `subtree pull` —
отдельных шагов не требует.

(Для того, кто ведёт сам шаблон: обновить `export/Стабильные`/`export/Бета` после правок на
соответствующей полной ветке — вручную, `subtree split` не работает:
```bash
TREE=$(git rev-parse "Стабильные:Сам проект/Godot_Template")
NEWCOMMIT=$(git commit-tree "$TREE" -m "Godot_Template/ из ветки Стабильные" -p export/Стабильные)
git branch -f export/Стабильные "$NEWCOMMIT"
git push origin export/Стабильные --force
```
то же самое для `Бета`/`export/Бета`.)

## Отправить правки обратно в шаблон

Если, работая в этом проекте, вы поправили что-то прямо внутри `Godot_Template/` (например,
починили баг в общем коде) — это не должно просто остаться только здесь. Отправьте изменения в
приёмную ветку этого проекта в репозитории шаблона:

Путь без пробела (например `Godot_Template`, как в Power_struggle) — обычный subtree push:
```bash
git subtree push --prefix=Godot_Template godot-template <ИмяЭтогоПроекта>
```

Путь с пробелом (например `Сам проект/Godot_Template`, как в Life_Operator) — `subtree push`
падает с тем же багом, что и `split` (см. предупреждение выше), поэтому вручную:
```bash
git fetch godot-template <ИмяЭтогоПроекта>
TREE=$(git rev-parse "HEAD:Сам проект/Godot_Template")
NEWCOMMIT=$(git commit-tree "$TREE" -m "Godot_Template/ из <ИмяЭтогоПроекта>" -p FETCH_HEAD)
git push godot-template "$NEWCOMMIT":<ИмяЭтогоПроекта>
```

`<ИмяЭтогоПроекта>` — `Life_Operator` или `Power_struggle`, приёмная ветка того же имени в
репозитории `Godot_Template`. Дальше это на усмотрение того, кто ведёт шаблон: посмотреть,
вручную влить удачное в `Бета` (а оттуда со временем в `Стабильные`) — не автоматика.

## Если нужно править общий код прямо здесь

Можно — subtree это обычные файлы, `git` не запрещает их менять. При следующем `subtree pull`
могут возникнуть обычные конфликты слияния для изменённых файлов — разрешаются как любой
`git merge`. См. также «Отправить правки обратно» выше — если правка нужна ВСЕМ проектам,
отправьте её в шаблон, а не держите только локально.

## Что НЕ входит в `Godot_Template/` (специфично для конкретного проекта)

Код, который нужен только этому проекту (игровая логика Power_struggle, экраны Life_Operator и
т.п.), не должен жить в `Godot_Template/` — иначе он потеряется/будет мешать при следующем
`subtree pull`. Держите его в соседней папке (например `GameClass/` в Power_struggle).
