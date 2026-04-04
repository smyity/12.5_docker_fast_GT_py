# 1. первоначальная сборка и установка зависимостей
FROM python:3.12-slim AS base

# 1.1 сначала сделать то, не меняется
# создание изолированного виртуального окружения и установка туда библиотек
RUN python -m venv /opt/venv
# временная активация окружения для данного этапа(любая команда будет выполняться внутри созданного venv)
ENV PATH="/opt/venv/bin:$PATH"

# обновление pip
RUN pip install --no-cache-dir --upgrade pip

# 1.2 затем то, что может измениться (список библиотек)
# создание и переход в директорию /app
WORKDIR /app
# копирование файла со списком нужных библиотек
COPY requirements.txt .

# установка библиотек из файла requirements.txt(fastapi, uvicorn, mysql-connector-python), без кэша
RUN pip install --no-cache-dir -r requirements.txt

# 2. сборка финального образа (с чистого листа)
FROM python:3.12-slim

# создание и переход в директорию /app (т.к. её на этом этапе снова нет)
WORKDIR /app

# перенос виртуального окружения со всеми установленными библиотеками (из - в)
COPY --from=base /opt/venv /opt/venv

# активация окружения для финального образа
ENV PATH="/opt/venv/bin:$PATH"

# копирование файлов в директорию /app
COPY . .

# запуск, Uvicorn ищет main.py в директории /app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]