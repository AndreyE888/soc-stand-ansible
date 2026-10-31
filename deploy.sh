#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "Шаг 1/3: Поднимаем VM (Vagrant)"
vagrant.exe up

echo "Шаг 2/3: Настраиваем VM (Ansible)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook.yml

echo "Шаг 3/3: Проверяем рубежи защиты (smoke-тесты)"
ansible-playbook -i provisioning/inventory.ini provisioning/playbook-smoke.yml

echo "Готово. Стенд развёрнут."
