# Não Teste o Código, Verifique Comportamento

Testes devem falhar somente se a aplicação **se comportar diferente**.
Eles devem testar *o que* o código da aplicação faz, não *como* faz.

- Testes que verificam *o que* a aplicação faz são **testes de comportamento**.
- Testes que quebram se o código da aplicação muda, mesmo que o comportamento seja mantido, são **teste frágeis**.

Vamos supor que temos uma database de bananas, chamada `GorillaDB`.
`GorillaDB` é uma database baseada em chave-valor que guarda bananas. Nós podemos salvar bananas:

```swift
let database = GorillaDB()
let banana = Banana()
database.save(banana: banana, key: "my-banana")
```

E podemos ler bananas:

```swift
let banana = database.load(key: "my-banana")
```

## Testes Frágeis

Como podemos testar esse comportamento? Um jeito seria checar o tamanho da database depois de salvar uma banana:

```swift
// GorillaDBTests.swift

func testSave_savesTheBananaToTheDatabase() {
  // Arrange: Create a database and get its original size.
  let database = GorillaDB()
  let originalSize = database.size

  // Act: Save a banana to the database.
  let banana = Banana()
  database.save(banana: banana, key: "test-banana")

  // Assert: The size of the database should have increased by one.
  XCTAssertEqual(database.size, originalSize + 1)
}
```


Imagine, no entanto, que o código fonte da `GorillaDB` mude. Para que a operação de leitura de bananas da database seja mais rápida, é mantido um cache com as bananas lidas com maior frequência. `GorillaDB.size` aumenta conforme o tamanho do cache aumenta, e nosso teste falha:

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/Screenshot_database_size_fail.png)

## Testes de Comportamento

O segredo para escrever testes de comportamento é determinar exatamente o que se espera que o código da aplicação faça.

No contexto do teste `testSave_savesTheBananaToTheDatabase`: qual é o comportamento esperado quando uma banana é salva na database? "Salvar" implica que essa banana pode ser lida mais tarde. Então, ao invés de testar que o tamanho da database aumenta, nós devemos testar que é possível ler uma banana.

```diff
// GorillaDBTests.swift

func testSave_savesTheBananaToTheDatabase() {
  // Arrange: Create a database and get its original size.
  let database = GorillaDB()
-  let originalSize = database.size

  // Act: Save a banana to the database.
  let banana = Banana()
  database.save(banana: banana, key: "test-banana")

-  // Assert: The size of the database should have increased by one.
-  XCTAssertEqual(database.size, originalSize + 1)
+  // Assert: The bananas saved to and loaded from the database should be the same.
+  XCTAssertEqual(database.load(key: "test-banana"), banana)
}
```

O segredo para escrever testes de comportamento é perguntar:

- O que exatamente o código dessa aplicação deve fazer?
- O meu teste está verificando *apenas* esse comportamento? Ou o teste pode falhar devido à forma como o código funciona?