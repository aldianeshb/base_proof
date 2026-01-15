# 🚀 Quick Deployment Guide

## 📋 Общий порядок деплоя

1. **Контракты** → Base Sepolia/Mainnet
2. **Backend API** → Railway/Render/другой хостинг
3. **Frontend** → Vercel

---

## 1️⃣ Контракты на Base

### Быстрый старт:

```bash
cd contracts

# 1. Создать .env файл
cp .env.example .env
# Отредактировать .env: добавить PRIVATE_KEY и BASESCAN_API_KEY

# 2. Установить OpenZeppelin
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# 3. Деплой на Base Sepolia
chmod +x scripts/deploy.sh
./scripts/deploy.sh sepolia
```

### Что нужно:
- **PRIVATE_KEY** - приватный ключ аккаунта для деплоя
- **BASESCAN_API_KEY** - получить на https://basescan.org/apis
- **Base Sepolia ETH** - получить из [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)

📖 **Подробная инструкция:** [docs/contract-deployment.md](./docs/contract-deployment.md)

---

## 2️⃣ Frontend на Vercel

### Шаг 1: Подключите репозиторий

1. Зайдите на https://vercel.com
2. Нажмите **"Add New..."** → **"Project"**
3. Импортируйте репозиторий `aldianeshb/baseproof`
4. В настройках проекта установите:
   - **Root Directory:** `frontend`
   - **Framework Preset:** `Next.js` (определится автоматически)

### Шаг 2: Добавьте переменные окружения

В разделе **Environment Variables** добавьте:

```
NEXT_PUBLIC_API_URL = https://your-api-url.com
NEXT_PUBLIC_PROOF_REGISTRY_ADDRESS = 0x... (адрес задеплоенного контракта)
NEXT_PUBLIC_CHAIN_ID = 84532 (или 8453 для mainnet)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID = ваш_project_id
```

**Важно:** Выберите окружения (Production, Preview, Development) для каждой переменной.

### Шаг 3: Деплой

Нажмите **"Deploy"** и дождитесь завершения (~2-3 минуты).

### Шаг 4: Получите WalletConnect Project ID

1. Зайдите на https://cloud.walletconnect.com
2. Создайте новый проект
3. Скопируйте Project ID
4. Добавьте в переменные окружения Vercel
5. Передеплойте проект

## 📚 Подробная инструкция

См. [docs/vercel-deployment.md](./docs/vercel-deployment.md) для детальной инструкции.

## ✅ После деплоя

1. Обновите README.md с ссылкой на деплой
2. Проверьте работу сайта
3. Протестируйте подключение кошелька
4. Проверьте загрузку данных

---

**Готово!** 🎉

