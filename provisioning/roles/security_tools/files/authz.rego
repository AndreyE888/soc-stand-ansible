package docker.authz

# Запрещаем всё по умолчанию
default allow = false

# Разрешаем, если нет ни одного сработавшего правила deny
allow {
    count(deny) == 0
}

# Проверяем, что запрос — это создание контейнера
is_container_create {
    input.Method == "POST"
    contains(input.Path, "/containers/create")
}

# Блокируем образы с тегом latest
deny[msg] {
    is_container_create
    endswith(input.Body.Image, ":latest")
    msg := "Использование тега :latest запрещено!"
}

# Требуем явное указание тега образа
deny[msg] {
    is_container_create
    not contains(input.Body.Image, ":")
    msg := "Укажите явный тег для образа!"
}

# Блокируем запуск привилегированных контейнеров
deny[msg] {
    is_container_create
    input.Body.HostConfig.Privileged == true
    msg := "Запуск привилегированных контейнеров запрещен!"
}

# Требуем явное указание пользователя (не пусто)
deny[msg] {
    is_container_create
    input.Body.User == ""
    msg := "Запуск от root запрещен! Задайте --user."
}

# Блокируем запуск от имени пользователя root
deny[msg] {
    is_container_create
    input.Body.User == "root"
    msg := "Запуск от root запрещен!"
}

# Блокируем запуск от UID 0
deny[msg] {
    is_container_create
    input.Body.User == "0"
    msg := "Запуск от UID 0 запрещен!"
}

# Список безопасных capabilities, которые разрешено добавлять
allowed_caps = {
    "CAP_CHOWN", "CAP_DAC_OVERRIDE", "CAP_FSETID", "CAP_FOWNER", "CAP_MKNOD",
    "CAP_NET_RAW", "CAP_SETGID", "CAP_SETUID", "CAP_SETFCAP", "CAP_SETPCAP",
    "CAP_NET_BIND_SERVICE", "CAP_SYS_CHROOT", "CAP_KILL", "CAP_AUDIT_WRITE"
}

# Блокируем добавление capabilities, не входящих в белый список
deny[msg] {
    is_container_create
    cap := input.Body.HostConfig.CapAdd[_]
    not allowed_caps[cap]
    msg := sprintf("Добавление capability '%s' запрещено! Разрешены только: %v", [cap, allowed_caps])
}

# Защита от CVE-2026-34040: блокируем пустое тело запроса на создание
deny[msg] {
    is_container_create
    not input.Body
    msg := "CVE-2026-34040: пустое тело запроса на create — возможна попытка обхода AuthZ"
}

# Защита от CVE-2026-34040: блокируем слишком большое тело запроса (больше 1MB)
deny[msg] {
    is_container_create
    input.Headers["Content-Length"]
    to_number(input.Headers["Content-Length"]) > 1048576
    msg := sprintf("CVE-2026-34040: тело запроса %s байт превышает лимит 1MB", [input.Headers["Content-Length"]])
}
