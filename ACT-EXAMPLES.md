# 🚀 Локальний запуск GitHub Actions пайплайнів з act

Цей документ описує як запускати всі GitHub Actions пайплайнів локально за допомогою інструменту **act**.

## 📋 Передумови

### 1. Встановлення act
```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Windows
choco install act-cli
```

### 2. Запуск Docker
```bash
# Переконайтеся що Docker запущений
docker info
```

## 🔧 Швидкий старт

### Автоматичний запуск
```bash
# Зробити скрипти виконуваними
chmod +x run-pipelines.sh quick-run.sh

# Запустити інтерактивний меню
./run-pipelines.sh

# Або швидкий запуск конкретного пайплайну
./quick-run.sh image-checker
```

## 📋 Ручні команди act

### 1. Image Update Checker
```bash
# Запуск з workflow_dispatch event
act workflow_dispatch -W .github/workflows/image-update-checker.yml

# Запуск з schedule event (daily)
act schedule -W .github/workflows/image-update-checker.yml

# Запуск з custom inputs
act workflow_dispatch -W .github/workflows/image-update-checker.yml \
  --input force_update=true
```

### 2. Build and Push Images
```bash
# Запуск з workflow_dispatch
act workflow_dispatch -W .github/workflows/build-images.yml

# Запуск з custom matrix
act workflow_dispatch -W .github/workflows/build-images.yml \
  --input images_matrix='[{"name":"ubuntu","channel":"lts","tag":"22.04","base_image":"ubuntu"}]'
```

### 3. .NET SDK Update
```bash
# Запуск з workflow_dispatch
act workflow_dispatch -W .github/workflows/dotnet-sdk-update.yml

# Запуск з schedule event (Tuesday)
act schedule -W .github/workflows/dotnet-sdk-update.yml
```

### 4. Webhook Update
```bash
# Запуск з repository_dispatch event
act -W .github/workflows/webhook-update.yml \
  --eventpath .github/events/webhook.json
```

### 5. Scheduled Update
```bash
# Запуск з workflow_dispatch
act workflow_dispatch -W .github/workflows/scheduled-update.yml

# Запуск з schedule event (monthly)
act schedule -W .github/workflows/scheduled-update.yml
```

## 🔐 Налаштування секретів

### Створення .secrets файлу
```bash
cat > .secrets << EOF
GITHUB_TOKEN=your_actual_github_token
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
EOF
```

### Створення .env файлу
```bash
cat > .env << EOF
GITHUB_TOKEN=your_actual_github_token
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
EOF
```

## 🎯 Приклади використання

### Тестування конкретного пайплайну
```bash
# Тестування Image Update Checker
act workflow_dispatch -W .github/workflows/image-update-checker.yml \
  --secret-file .secrets \
  --verbose

# Тестування Build Images з конкретними параметрами
act workflow_dispatch -W .github/workflows/build-images.yml \
  --input images_matrix='[{"name":"ubuntu","channel":"lts","tag":"22.04","base_image":"ubuntu"}]' \
  --secret-file .secrets
```

### Запуск всіх пайплайнів послідовно
```bash
# Створення скрипта для запуску всіх
cat > run-all.sh << 'EOF'
#!/bin/bash
echo "🚀 Running all workflows..."

echo "1. Image Update Checker..."
act workflow_dispatch -W .github/workflows/image-update-checker.yml

echo "2. Build and Push Images..."
act workflow_dispatch -W .github/workflows/build-images.yml

echo "3. .NET SDK Update..."
act workflow_dispatch -W .github/workflows/dotnet-sdk-update.yml

echo "4. Webhook Update..."
act -W .github/workflows/webhook-update.yml

echo "5. Scheduled Update..."
act workflow_dispatch -W .github/workflows/scheduled-update.yml

echo "✅ All workflows completed!"
EOF

chmod +x run-all.sh
./run-all.sh
```

## 🔍 Діагностика

### Перевірка статусу
```bash
# Перевірка версії act
act --version

# Перевірка доступних workflows
act --list

# Dry run (без виконання)
act --dryrun
```

### Логування
```bash
# Детальне логування
act --verbose

# Логування в файл
act workflow_dispatch -W .github/workflows/image-update-checker.yml \
  --verbose > workflow.log 2>&1
```

## ⚠️ Обмеження

### Що працює локально:
- ✅ Базові GitHub Actions
- ✅ Docker команди
- ✅ Shell скрипти
- ✅ Python скрипти
- ✅ Перевірка синтаксису

### Що може не працювати:
- ❌ GitHub API виклики (потребують реального токена)
- ❌ Container Registry автентифікація
- ❌ Секрети та змінні середовища
- ❌ Matrix стратегії (обмежена підтримка)

## 🚨 Розв'язання проблем

### Помилка "Docker not running"
```bash
# Запустити Docker Desktop або Docker daemon
open -a Docker  # macOS
sudo systemctl start docker  # Linux
```

### Помилка "act not found"
```bash
# Перевірити PATH
which act
echo $PATH

# Перевстановити act
brew uninstall act && brew install act
```

### Помилка з секретами
```bash
# Створити dummy секрети для тестування
cat > .secrets << EOF
GITHUB_TOKEN=dummy_token_for_testing
DOCKER_USERNAME=dummy_user
DOCKER_PASSWORD=dummy_pass
EOF

# Запустити без секретів
act workflow_dispatch -W .github/workflows/image-update-checker.yml
```

## 📚 Корисні посилання

- [act GitHub Repository](https://github.com/nektos/act)
- [act Documentation](https://nektosact.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)

## 🎉 Висновок

З act ви можете:
- 🧪 Тестувати пайплайни локально перед push
- 🔍 Діагностувати проблеми в ізольованому середовищі
- ⚡ Швидко ітераціювати над змінами
- 💰 Економити GitHub Actions minutes
- 🚀 Розробляти та тестувати offline
