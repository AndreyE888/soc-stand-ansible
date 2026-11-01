#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "Шаг 1/4: Установка зависимостей Ansible"
ansible-galaxy collection install community.docker community.crypto

echo "Шаг 2/4: Поднимаем VM (Vagrant)"
vagrant.exe up

echo "Шаг 3/4: Настраиваем VM (Ansible)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook.yml

echo "Шаг 4/4: Проверяем рубежи защиты (smoke-тесты)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook-smoke.yml

echo "Готово. Стенд развернут."