# nhk-mac

           _     _
     _ __ | |__ | | __     _ __ ___   __ _  ___
    | '_ \| '_ \| |/ /____| '_ ` _ \ / _` |/ __|
    | | | | | | |   <_____| | | | | | (_| | (__
    |_| |_|_| |_|_|\_\    |_| |_| |_|\__,_|\___|

A CLI for quickly setting up a new macOS workstation.

## Usage

1. Open Terminal.

2. Download the zip file.

```bash
curl -L https://github.com/nickolashkraus/nhk-mac/archive/master.zip -o nhk-mac.zip
unzip -q nhk-mac.zip
mv nhk-mac-master nhk-mac
rm nhk-mac.zip
cd nhk-mac
```

3. Run `nhk-mac`.

```bash
./nhk-mac
```

## TODO
- [ ] Print public SSH key to console.
- [ ] Check that public SSH key added to GitHub before continuing.
- [ ] Fix the following:

```bash
rm: /Users/x/.aws/config: No such file or directory
rm: /Users/x/.ssh/config: No such file or directory
rm: /Users/x/.vim/.en.utf-8.add: No such file or directory
...
```
