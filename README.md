# Paraíba Lanches - Aplicativo Cliente (Mobile)

Este é o aplicativo mobile voltado para os clientes da **Paraíba Lanches**, onde os usuários podem visualizar o cardápio, fazer pedidos, gerenciar perfil (com foto e endereço), usar cupons de desconto e acompanhar o status dos pedidos.

O aplicativo se comunica diretamente com a API do **Next-Hamburgueria** (Backend).

## 🛠️ Tecnologias
- **Framework**: Flutter
- **Linguagem**: Dart
- **Gerenciamento de Estado**: Riverpod (`hooks_riverpod`, `flutter_riverpod`)
- **Roteamento**: GoRouter
- **Requisições HTTP**: Dio
- **Armazenamento Local**: SharedPreferences / Secure Storage (via Flutter Secure Storage)
- **Integrações Externas**: ViaCEP (Busca de endereço por CEP)

## ✨ Funcionalidades
- **Autenticação**: Cadastro completo (CPF com validação matemática, CEP com busca automática, etc.) e Login (JWT).
- **Catálogo / Cardápio**: Vitrine de produtos organizados por categoria (Hambúrgueres, Bebidas, Sobremesas, etc.).
- **Carrinho e Checkout**: Gerenciamento de itens do pedido com cálculo de distância/frete e aplicação de cupons de desconto.
- **Meus Pedidos**: Histórico completo de pedidos realizados e acompanhamento de status.
- **Perfil de Usuário**: Edição de dados pessoais e upload de foto de perfil (Avatar).

## 🚀 Como Rodar o Projeto (Localmente)

**Pré-requisitos**:
- Ter o Flutter SDK instalado (versão mais recente recomendada).
- Ter um Emulador (Android/iOS) rodando ou dispositivo físico conectado via ADB.
- Ter o Backend (`next-hamburgueria`) rodando localmente (ou em um servidor acessível).

**Passo a passo**:

1. Clone e entre na pasta do projeto:
```bash
cd paraiba-lanches
```

2. Instale as dependências do Flutter:
```bash
flutter pub get
```

3. Configuração de Variáveis (Acesso à API):
O app precisa saber onde o backend está hospedado. Por padrão, ele usa a configuração definida no serviço de API (ex: `http://10.0.2.2:3000` para emuladores Android ou `http://localhost:3000` para iOS).
*Nota: Verifique o arquivo `lib/core/constants.dart` ou `api_client.dart` para confirmar as URLs da API se estiver testando em rede.*

4. Execute o App:
```bash
flutter run
```

## 📂 Estrutura do Projeto (Clean Architecture Simplificada)

O projeto segue uma estrutura baseada em features, visando escalabilidade e facilidade de manutenção:

- **`lib/core/`**: Funcionalidades globais, utilitários, validadores (ex: Validador de CPF), temas, rotas (GoRouter) e o cliente HTTP base (Dio).
- **`lib/models/`**: Classes de dados e serialização (ex: `user_model.dart`, `product_model.dart`).
- **`lib/providers/`**: Provedores Riverpod globais (ex: Autenticação e Carrinho).
- **`lib/services/`**: Camada de comunicação com a API (ex: `auth_service.dart`, `order_service.dart`, `viacep_service.dart`).
- **`lib/views/`**: Telas do aplicativo (UI), divididas por domínio (ex: `/home`, `/auth`, `/cart`, `/profile`, `/orders`).

---

**Desenvolvido com 💙 para a Paraíba Lanches.**
