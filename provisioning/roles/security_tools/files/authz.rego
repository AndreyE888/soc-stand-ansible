package docker.authz

default allow = false

allow {
    count(deny) == 0
}

is_container_create {
    input.Method == "POST"
    contains(input.Path, "/containers/create")
}

deny[msg] {
    is_container_create
    endswith(input.Body.Image, ":latest")
    msg := "Использование тега :latest запрещено!"
}

deny[msg] {
    is_container_create
    not contains(input.Body.Image, ":")
    msg := "Укажите явный тег для образа!"
}

deny[msg] {
    is_container_create
    input.Body.HostConfig.Privileged == true
    msg := "Запуск привилегированных контейнеров запрещен!"
}

deny[msg] {
    is_container_create
    input.Body.User == ""
    msg := "Запуск от root запрещен! Задайте --user."
}

deny[msg] {
    is_container_create
    input.Body.User == "root"
    msg := "Запуск от root запрещен!"
}

deny[msg] {
    is_container_create
    input.Body.User == "0"
    msg := "Запуск от UID 0 запрещен!"
}

