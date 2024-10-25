수정 사항 반영이 제대로 안되는 버그로 인해 변경이 발생하면 ./config/karabiner/karabiner.json 을 삭제하고 symbolic link 다시 만들어주기

```zsh
ln -s /Users/hyzoon/dotfiles/karabiner/karabiner.json /Users/hyzoon/.config/karabiner/karabiner.json
```