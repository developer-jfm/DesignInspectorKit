# DesignInspectorKit

Uma biblioteca Swift para inspeção e debug visual de interfaces iOS.

## Requisitos

- iOS 14.0+
- Swift 6.2+
- Xcode 16.0+

## Instalação

### Swift Package Manager

Adicione o pacote ao seu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seu-usuario/DesignInspectorKit.git", from: "1.0.0")
]
```

Ou via Xcode: **File → Add Package Dependencies...**

## Uso

```swift
import DesignInspectorKit

// Inicialize o DesignInspector
let inspector = DesignInspector()
inspector.enable()
```

## Estrutura do Projeto

```
Sources/
└── DesignInspectorKit/
    └── DesignInspectorKit.swift    # Código fonte principal
Tests/
└── DesignInspectorKitTests/
    └── DesignInspectorKitTests.swift # Testes unitários
```

## Desenvolvimento

### Build

```bash
swift build
```

### Testes

```bash
swift test
```

### Lint

```bash
swiftlint
```

## Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.
