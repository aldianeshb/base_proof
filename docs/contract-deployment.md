# 📝 Деплой контрактов BaseProof на Base

Пошаговая инструкция по деплою смарт-контрактов BaseProof на Base Sepolia (testnet) и Base Mainnet.

## 📋 Предварительные требования

1. ✅ **Foundry установлен** - [Install Foundry](https://book.getfoundry.sh/getting-started/installation)
2. ✅ **Base Sepolia ETH** - Для деплоя на testnet (получить из [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet))
3. ✅ **Base Mainnet ETH** - Для деплоя на mainnet
4. ✅ **Basescan API Key** - Для верификации контрактов (получить на [Basescan](https://basescan.org/apis))

## 🔧 Настройка

### Шаг 1: Установка зависимостей

```bash
cd contracts

# Установить OpenZeppelin (если еще не установлен)
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Шаг 2: Настройка переменных окружения

```bash
# Скопировать пример файла
cp .env.example .env

# Отредактировать .env
nano .env  # или используйте ваш редактор
```

Заполните `.env` файл:

```bash
# Приватный ключ аккаунта для деплоя (БЕЗ 0x префикса)
PRIVATE_KEY=your_private_key_here

# Сеть (sepolia или mainnet)
NETWORK=sepolia

# RPC URLs
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASE_MAINNET_RPC_URL=https://mainnet.base.org

# Basescan API Key (для верификации контрактов)
BASESCAN_API_KEY=your_basescan_api_key_here
```

⚠️ **ВАЖНО:** Никогда не коммитьте `.env` файл в git!

### Шаг 3: Получение Basescan API Key

1. Зайдите на https://basescan.org
2. Создайте аккаунт или войдите
3. Перейдите в [API-KEYs](https://basescan.org/apis)
4. Создайте новый API key
5. Скопируйте ключ в `.env` файл

## 🚀 Деплой на Base Sepolia (Testnet)

### Способ 1: Использование скрипта (рекомендуется)

```bash
cd contracts

# Сделать скрипт исполняемым
chmod +x scripts/deploy.sh

# Деплой на Sepolia
./scripts/deploy.sh sepolia
```

### Способ 2: Ручной деплой

```bash
cd contracts

# Установить переменные окружения
export PRIVATE_KEY=your_private_key
export NETWORK=sepolia
export BASESCAN_API_KEY=your_api_key

# Деплой
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
```

### Ожидаемый вывод:

```
Deploying ProofRegistry...
ProofRegistry deployed at: 0x1234...
Deploying ProofVerifier...
ProofVerifier deployed at: 0x5678...

=== Deployment Summary ===
Network: sepolia
ProofRegistry: 0x1234...
ProofVerifier: 0x5678...
```

**Сохраните эти адреса!** Они понадобятся для настройки API и фронтенда.

## 🌐 Деплой на Base Mainnet

⚠️ **ВНИМАНИЕ:** Деплойте на mainnet только после тщательного тестирования на Sepolia!

### Способ 1: Использование скрипта

```bash
cd contracts
./scripts/deploy.sh mainnet
```

### Способ 2: Ручной деплой

```bash
cd contracts

export PRIVATE_KEY=your_private_key
export NETWORK=mainnet
export BASESCAN_API_KEY=your_api_key

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_mainnet \
  --broadcast \
  --verify
```

## ✅ После деплоя

### 1. Проверьте контракты на Basescan

- Base Sepolia: https://sepolia.basescan.org
- Base Mainnet: https://basescan.org

Найдите ваши контракты по адресам и убедитесь, что они верифицированы.

### 2. Обновите конфигурацию Backend

```bash
cd backend
# Отредактируйте .env
nano .env
```

Добавьте:
```bash
PROOF_REGISTRY_ADDRESS=0x... # адрес ProofRegistry
NETWORK=sepolia # или mainnet
```

### 3. Обновите конфигурацию Frontend

```bash
cd frontend
# Отредактируйте .env.local
nano .env.local
```

Добавьте:
```bash
NEXT_PUBLIC_PROOF_REGISTRY_ADDRESS=0x... # адрес ProofRegistry
NEXT_PUBLIC_CHAIN_ID=84532 # для Sepolia, 8453 для Mainnet
```

### 4. Обновите переменные окружения Vercel

1. Зайдите в Vercel Dashboard
2. Settings → Environment Variables
3. Обновите `NEXT_PUBLIC_PROOF_REGISTRY_ADDRESS`
4. Передеплойте проект

### 5. Обновите README.md

Добавьте адреса контрактов в README:

```markdown
## 🔗 Deployed Contracts

### Base Sepolia (Testnet)
- **ProofRegistry:** [0x...](https://sepolia.basescan.org/address/0x...)
- **ProofVerifier:** [0x...](https://sepolia.basescan.org/address/0x...)

### Base Mainnet
- **ProofRegistry:** [0x...](https://basescan.org/address/0x...)
- **ProofVerifier:** [0x...](https://basescan.org/address/0x...)
```

## 🧪 Тестирование после деплоя

### 1. Проверьте контракты локально

```bash
cd contracts
forge test
```

### 2. Проверьте через API

```bash
# Запустите backend
cd backend
npm run dev

# Проверьте health endpoint
curl http://localhost:3001/health

# Проверьте stats
curl http://localhost:3001/stats
```

### 3. Проверьте через Frontend

1. Запустите frontend локально или откройте деплой
2. Подключите кошелек
3. Проверьте загрузку данных

## 🐛 Решение проблем

### Проблема: Недостаточно ETH для газа

**Решение:**
- Для Sepolia: получите ETH из [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
- Для Mainnet: убедитесь, что у вас достаточно ETH на аккаунте

### Проблема: Ошибка верификации контракта

**Решение:**
1. Проверьте, что `BASESCAN_API_KEY` правильный
2. Убедитесь, что контракт скомпилирован с теми же настройками
3. Попробуйте верифицировать вручную через Basescan

### Проблема: RPC URL недоступен

**Решение:**
1. Проверьте, что RPC URL правильный
2. Попробуйте альтернативный RPC:
   - Alchemy: https://base-mainnet.g.alchemy.com/v2/YOUR_API_KEY
   - Infura: https://base-mainnet.infura.io/v3/YOUR_API_KEY

### Проблема: Контракт не деплоится

**Решение:**
1. Проверьте баланс аккаунта
2. Убедитесь, что приватный ключ правильный
3. Проверьте логи ошибок в выводе forge

## 📚 Полезные ссылки

- [Base Documentation](https://docs.base.org)
- [Foundry Book](https://book.getfoundry.sh)
- [Basescan](https://basescan.org)
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)

## 🔐 Безопасность

- ✅ Никогда не коммитьте `.env` файл
- ✅ Используйте отдельный аккаунт для деплоя
- ✅ Храните приватные ключи в безопасном месте
- ✅ Проверяйте контракты перед деплоем на mainnet
- ✅ Используйте мультисиг для production контрактов

---

**После успешного деплоя обновите документацию и начните тестирование!** 🚀

