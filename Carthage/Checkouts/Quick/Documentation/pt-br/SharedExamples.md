# Reduzindo Teste Boilerplate com Assertions Compartilhados

Em alguns casos, o mesmo conjunto de especificações se aplica a múltiplos objetos.

Por exemplo, considere um protocol chamado `Edible` (comestível). Quando um golfinho come algo `Edible`, ele fica feliz. `Mackerel` (um tipo de peixe) e `Cod` (bacalhau) são comestíveis. Quick permite testar facilmente que um golfinho fica feliz quando come qualquer um desses peixes.

O exemplo abaixo define um conjunto de "exemplos compartilhados" para "algo comestível", e especifica que tanto `Mackerel` quanto `Cod` se comportam como "algo comestível":


```swift
// Swift

import Quick
import Nimble

class EdibleSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("something edible") { (sharedExampleContext: @escaping SharedExampleContext) in
      it("makes dolphins happy") {
        let dolphin = Dolphin(happy: false)
        let edible = sharedExampleContext()["edible"]
        dolphin.eat(edible)
        expect(dolphin.isHappy).to(beTruthy())
      }
    }
  }
}

class MackerelSpec: QuickSpec {
  override func spec() {
    var mackerel: Mackerel!
    beforeEach {
      mackerel = Mackerel()
    }

    itBehavesLike("something edible") { ["edible": mackerel] }
  }
}

class CodSpec: QuickSpec {
  override func spec() {
    var cod: Cod!
    beforeEach {
      cod = Cod()
    }

    itBehavesLike("something edible") { ["edible": cod] }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickConfigurationBegin(EdibleSharedExamplesConfiguration)

+ (void)configure:(Configuration *configuration) {
  sharedExamples(@"something edible", ^(QCKDSLSharedExampleContext exampleContext) {
    it(@"makes dolphins happy", ^{
      Dolphin *dolphin = [[Dolphin alloc] init];
      dolphin.happy = NO;
      id<Edible> edible = exampleContext()[@"edible"];
      [dolphin eat:edible];
      expect(dolphin.isHappy).to(beTruthy())
    });
  });
}

QuickConfigurationEnd

QuickSpecBegin(MackerelSpec)

__block Mackerel *mackerel = nil;
beforeEach(^{
  mackerel = [[Mackerel alloc] init];
});

itBehavesLike(@"something edible", ^{ return @{ @"edible": mackerel }; });

QuickSpecEnd

QuickSpecBegin(CodSpec)

__block Mackerel *cod = nil;
beforeEach(^{
  cod = [[Cod alloc] init];
});

itBehavesLike(@"something edible", ^{ return @{ @"edible": cod }; });

QuickSpecEnd
```

Exemplos compartilhados podem incluir qualquer número de blocos `it`, `context` e `describe`. Isso economiza *muito* quando deve-se escrever os mesmos testes para diferentes objetos.

Em alguns casos, nenhum `context` adicional é necessário. Em Swift, é possível usar `sharedExamples` closures que não recebem parâmetros. Isso pode ser útil quando se esta algum estado global:


```swift
// Swift

import Quick

sharedExamples("everything under the sea") {
  // ...
}

itBehavesLike("everything under the sea")
```

> Em Objective-C, é necessário passar um bloco que recebe um `QCKDSLSharedExampleContext`, mesmo se esse argumento não for usado. Desculpe, mas é assim que a banda toca! :trumpet: :notes:

Também é possível "focar" exemplos compartilhados usando a função `fitBehavesLike`.
