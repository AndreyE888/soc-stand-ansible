#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "Шаг 1/4: Установка коллекций Ansible и проверка ключей"
ansible-galaxy collection install community.docker community.crypto

if command -v cmd.exe &> /dev/null; then
    if [ ! -f ~/.ssh/vagrant_insecure_key ]; then
        echo "Ключ Vagrant не найден. Копируем из Windows..."
        mkdir -p ~/.ssh
        # Получаем путь к Windows-папке и конвертируем его через wslpath
        WIN_HOME=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
        WSL_HOME=$(wslpath "$WIN_HOME")
        VAGRANT_DIR="$WSL_HOME/.vagrant.d"
        # Копируем ключ
        cp "$VAGRANT_DIR/vagrant.key.ed25519" ~/.ssh/vagrant_insecure_key 2>/dev/null || \
        cp "$VAGRANT_DIR/insecure_private_key" ~/.ssh/vagrant_insecure_key 2>/dev/null || true
        chmod 600 ~/.ssh/vagrant_insecure_key 2>/dev/null || true
    fi
fi
echo "Шаг 2/4: Поднимаем VM (Vagrant)"
if command -v vagrant.exe &> /dev/null; then
    vagrant.exe up
else
    vagrant up
fi

echo "Шаг 3/4: Настраиваем VM (Ansible)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook.yml

echo "Шаг 4/4: Проверяем рубежи защиты (smoke-тесты)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook-smoke.yml

echo "Готово. Стенд развернут."
