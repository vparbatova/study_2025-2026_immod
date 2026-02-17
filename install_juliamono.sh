#!/bin/bash

# Создать директории
mkdir -p ~/texmf/tex/latex/juliamono
mkdir -p ~/texmf/fonts/truetype/juliamono

# Скачать и распаковать
cd /tmp
wget http://mirrors.ctan.org/fonts/juliamono.zip
unzip juliamono.zip
cd juliamono

# Скопировать файлы
cp *.sty ~/texmf/tex/latex/juliamono/
cp *.ttf ~/texmf/fonts/truetype/juliamono/

# Обновить базы
texhash ~/texmf
fc-cache -fv

echo "Juliamono установлен!"
