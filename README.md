# 소비학습

소비 전용 가계부 앱.  
서버 없이 기기 안에서 온디바이스 학습으로 **소비 패턴을 스스로 학습하고 지출을 예측**합니다.

## Motivation

기존 가계부 앱은 수입과 지출을 모두 기록해야 해서 꾸준히 쓰기 번거로웠고,  
기록은 쌓여도 그걸 다시 들여다보는 건 귀찮았고, 지난달 지출은 그저 지난달 지출로 끝났습니다.  
그래서 **지출 기록만 남기는 대신, 그 기록을 학습에 활용하는 가계부**를 만들기로 했습니다.  
서버로 데이터를 보내지 않고 기기 안에서만 학습/예측이 이루어지도록 하는 것을 목표로 삼았습니다.

## 기능 소개

| 소비 기록 | 지출 예측 | 음성으로 기록 |
| :---: | :---: | :---: |
| 날짜를 선택해 금액·카테고리·메모를 기록 | 과거 지출을 통계적으로 분석해 이번 달 예측 | 음성으로 말하면 카테고리까지 자동으로 예측 |
| <img height="400" alt="소비기록" src="https://github.com/user-attachments/assets/d5adffb1-7c5a-4439-8093-d30ed17ed3aa" /> | <img height="400" alt="지출예측" src="https://github.com/user-attachments/assets/7f3f72f8-4699-4b2b-aa36-64374ea04983" /> | <img height="400" alt="음성으로기록" src="https://github.com/user-attachments/assets/76edb02d-977b-4ad1-bf6e-67ef17076e60" /> |

- **소비 기록**
  - 일반적인 가계부 앱과 비슷합니다.
  - 카테고리는 기본 제공 외에 커스텀 추가/수정/삭제가 가능합니다.
- **지출 예측**
  - 과거 지출을 학습하는 모델 없이, 통계만으로 패턴을 판단합니다.
  - 이번 달 일별/카테고리별로 얼마를 쓸지 미리 보여줍니다.
- **음성으로 기록**
  - 말한 내용에서 금액과 카테고리를 온디바이스로 자동 인식합니다.
  - 예측된 카테고리를 저장하면 즉시 그 내용으로 재학습되어 다음 예측에 반영됩니다.
 
---
 
# Issue Points

조금 더 자세하게 쓰여있는 노션 링크입니다.

[📝 노션: 지출 예측, CreateML 대신 통계를 택한 이유](https://app.notion.com/p/CreateML-3a380f28c3ad80ecbad8d6d3f241a47a?source=copy_link)  
[📝 노션: 유동적인 카테고리 kNN 온디바이스 학습으로 자동 분류하기](https://app.notion.com/p/kNN-3a380f28c3ad8002a306f6a234e3acb2?source=copy_link)  
[📝 노션: 카테고리가 항상 "기타"였던 이유, mlmodelc](https://app.notion.com/p/mlmodelc-3a380f28c3ad802ba63fe78d2af7e8e2?source=copy_link)  

## 1. 지출 예측, CreateML 대신 통계를 택한 이유

### 📈 통계를 택하기까지

지출 예측은 처음엔 CreateML의 회귀(Regressor) 모델로 접근했습니다.  
날짜별/카테고리별 숫자를 예측하는 문제였으니, 전형적인 회귀 문제라고 생각했습니다.

<img height="450" alt="image" src="https://github.com/user-attachments/assets/f15835ba-dc6b-4253-aa92-2f2980ebdaed" />

그런데 조건이 하나 걸렸습니다.  
서버 없이 기기 안에서, 사용자 한 명의 지출만으로 계속 재학습되어야 했습니다.  
CreateML Tabular Regression이 제공하는 알고리즘은  
[온디바이스 지속 학습이 가능한 모델 타입(신경망, 파이프라인, kNN)](https://apple.github.io/coremltools/docs-guides/source/updatable-model-examples.html)에는 해당하지 않았습니다.

회귀 모델을 계속 붙잡고 있을 이유가 없다고 판단한 뒤, 예측이 실제로 필요로 하는 게 무엇인지 다시 짚어봤습니다.  
예를 들어 매달 15일마다 나가는 구독료처럼 반복되는 지출은,  
복잡한 모델 없이도 과거 15일들의 평균과 표준편차만 비교하면 패턴인지 아닌지 판단할 수 있었습니다.  
굳이 예측 모델을 학습시키지 않아도, "이 값들이 서로 얼마나 일관된가"만 계산하면 충분했습니다.

### ✍️ 수식으로 옮기기

값이 평균에서 얼마나 떨어져 있는지를 나타내는 게 표준편차($\sigma$)입니다.

$$\sigma = \sqrt{\frac{1}{n}\sum_{i=1}^{n}(x_i - \mu)^2}$$

다만 표준편차는 지출 금액처럼 값의 크기가 다르면 그대로 비교하기 어렵습니다.  
매달 10만 원씩 나가는 지출과 매달 1만 원씩 나가는 지출은,  
흔들리는 정도가 같아도 표준편차 값 자체는 다르게 나오기 때문입니다.

그래서 표준편차를 평균($\mu$)으로 나눠,  
"평균 대비 상대적으로 얼마나 흔들리는지"로 바꾼 값이 변동계수(CV)입니다.

$$CV = \frac{\sigma}{\mu}$$

변동계수가 0.5 이하면 값들이 충분히 일관되다고 보고 패턴으로 인정했습니다.  
0.5보다 크면 평균에서 가장 먼 값부터 하나씩 제외하며 다시 계산합니다.

> 0.5는 실제 지출 패턴을 가정해 몇 가지 예시로 계산해보고 정한 값입니다.  
> 임계값을 0.3처럼 빡빡하게 잡으면 어느 정도 규칙이 있는 소비까지 걸러졌고,  
> 0.7 이상으로 느슨하게 잡으면 충동구매나 여행경비처럼 불규칙한 소비까지 패턴으로 오인했습니다.  
> 규칙적인 소비는 인정하면서 불규칙한 소비는 걸러내는 경계로 0.5를 택했습니다.  

```swift
private func reliableAverage(of samples: [Int]) -> Int? {
    guard samples.count >= minimumSampleCount else { return nil }

    let mean = Double(samples.reduce(0, +)) / Double(samples.count)
    let variance = samples.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / Double(samples.count)
    let coefficientOfVariation = variance.squareRoot() / mean

    if coefficientOfVariation <= coefficientOfVariationThreshold {
        return Int(mean)
    }

    // 이상치 제거 후 재계산
    ...
}
```

> 참고: 카테고리별 예측은 이런 신뢰도 판단 없이, 과거 몇 달간 그 카테고리에 쓴 금액의 평균만 냅니다.

두 로직 모두 별도로 학습된 모델 파일이 없습니다.  
코드의 계산식 자체가 결과의 전부이기 때문에, 지출이 기록되는 즉시 다시 계산해 반영할 수 있었습니다.

---

## 2. 유동적인 카테고리, kNN으로 온디바이스 분류하기

### 🎙️ kNN을 택하기까지

"스타벅스 4500원"라고 말하면 금액과 메모는 물론, 카테고리까지 자동으로 골라주는 걸 목표로 했습니다.  
그런데 카테고리를 고르는 분류기를 만들려면, 먼저 "어떤 카테고리들 중에서 고를지"부터 정해져 있어야 했습니다.

문제는 이 `소비학습` 서비스는 카테고리가 고정되어 있지 않다는 점이었습니다.  
사용자가 언제든 새 카테고리를 만들거나 지울 수 있기 때문에,  
"카테고리 N개짜리 모델 하나"를 고정해서 만들어 넣는 방식은 쓸 수 없었습니다.

<img height="450" alt="image" src="https://github.com/user-attachments/assets/ebc7c682-bd57-4233-b7bb-99f50815875f" />

CreateML Tabular Classification이 제공하는 알고리즘도 살펴봤지만,  
모두 학습이 끝나면 하나의 고정된 규칙으로 굳어지는 방식이라  
마찬가지로 [온디바이스 지속 학습이 가능한 모델 타입(신경망, 파이프라인, kNN)](https://apple.github.io/coremltools/docs-guides/source/updatable-model-examples.html)에는 해당하지 않았습니다.

이 중 kNN은 "카테고리가 몇 개"라고 미리 정해두는 대신,  
그동안 쌓인 데이터 중 새 입력과 가장 가까운 데이터 포인트 몇 개를 찾아 다수결로 정하는 방식입니다.  
사용자가 카테고리를 새로 만들어도 모델 자체를 다시 설계할 필요가 없어, 방식을 kNN으로 결정했습니다.

다만 kNN은 CreateML.app이나 CreateML.framework에는 대응하는 타입이 없었습니다.  
coremltools 문서의 예제도 Swift가 아니라 Python 코드였고,  
그래서 모델을 만드는 도구를 Python coremltools로 사용하였습니다.

### 🔤 한글을 벡터로 옮기기

kNN은 숫자로 된 벡터를 입력으로 받습니다.  
메모는 "스타벅스" 같은 한글 텍스트이니, 이걸 어떤 규칙으로 벡터로 바꿀지가 문제였습니다.

Apple이 제공하는 `NLEmbedding`을 쓰면 될 거라 생각했지만,  
확인해보니 한국어를 지원하지 않았습니다.
```swift
let embedding = NLEmbedding.wordEmbedding(for: .korean)
print(embedding) // nil
```

가장 단순하게는 글자 하나하나를 세는 방식을 생각했지만,  
한글은 완성된 글자의 조합 경우의 수가 많아 vocabulary가 지나치게 커지는 문제가 있었습니다.  
> vocabulary란, 벡터의 각 자리(차원)가 어떤 글자를 뜻하는지 정해둔 고정된 사전입니다.  

그래서 한글 글자를 초성/중성/종성으로 분해하는 방식을 택했습니다.  
"스"는 초성 "ㅅ"과 중성 "ㅡ"로 쪼개는 식입니다.  
자모 단위로 쪼개면 조각의 종류가 훨씬 적고(자음 19개, 모음 21개, 받침 27개),  
학습 데이터에 없던 메모라도 vocabulary에 없는 글자를 만날 일이 없습니다.

```python
# 완성형 한글은 AC00부터 초성*(21*28) + 중성*28 + 종성 순으로 배치되어 있어,
# 시작 코드(AC00)를 뺀 나머지를 588, 28로 나눈 몫/나머지가 각각 초성/중성/종성 인덱스가 된다
def decompose_hangul(char):
    code = ord(char)
    offset = code - HANGUL_BASE
    cho = offset // (21 * 28)
    jung = (offset % (21 * 28)) // 28
    jong = offset % 28
    return (CHOSUNG[cho], JUNGSUNG[jung], JONGSUNG[jong])
```

그런데 벡터화를 해보니 놓친 부분이 하나 있었습니다.  
초성 "ㄱ"과 종성 "ㄱ"이 같은 문자로 표현되다 보니,  
"역"(받침 ㄱ)과 "가"(첫소리 ㄱ)이 같은 벡터 차원에 섞여 카운트되었습니다.  
그래서 종성에는 "_" 접두어를 붙여, 초성과 종성이 서로 다른 토큰으로 구분되도록 했습니다.

### 🔁 학습시키고, 검증하고, 다시 학습시키기

앱을 처음 설치한 시점부터도 어느 정도 예측이 되도록 학습 데이터가 필요했습니다.  
기본 카테고리를 바탕으로 500개로 시드 데이터를 만들어 학습시켰고,  
시드에 없는 새 메모 55개로 검증해 60%의 정확도를 확인했습니다.

처음부터 완벽한 정확도가 목표가 아니라,  
사용자가 실제로 지출을 기록할 때마다 데이터가 쌓이며 갈수록 정확해지는 구조가 목표였습니다.  
그래서 카테고리 예측 결과를 사용자가 확인하고 저장하면,  
`MLUpdateTask`로 그 자리에서 즉시 재학습되도록 만들었습니다.

---

## 3. 카테고리가 항상 "기타"였던 이유

### 🔍 증상과 원인 추적

음성 추가 기능에서 "스타벅스"처럼 시드 데이터에 명확히 있는 상호명을 말해도,  
예측 결과가 항상 "기타"(폴백값)로만 나왔습니다.

폴백값은 모델(`MLModel?`)이 `nil`이거나 벡터화가 실패했을 때만 반환됩니다.  
확인해보니 벡터화 결과는 정상이었고, `model`(`MLModel`) 프로퍼티만 `nil`이었습니다.  
즉 `init` 시점의 모델 로드 단계에서 이미 실패하고 있었던 것입니다.
```swift
guard let bundledCompiledURL = Bundle.main.url(forResource: "CategoryClassifier", withExtension: "mlmodel") else {
    return
}
```

### 🗂️ 빌드 산출물을 직접 확인하기

Xcode 내비게이터에는 `CategoryClassifier.mlmodel`이 있는데 `nil`이 반환되는게 이상해서,  
내비게이터가 아니라 실제 빌드 산출물을 직접 뒤져봤습니다.

```
find ~/Library/Developer/Xcode/DerivedData/SpendLearning-*/Build/Products/Debug-iphonesimulator/SpendLearning.app -iname "*CategoryClassifier*"

# 결과: .../SpendLearning.app/CategoryClassifier.mlmodelc
```
`.mlmodel`은 안나오고, 확장자가 다른 `CategoryClassifier.mlmodelc`만 들어 있었습니다.  
Xcode는 `.mlmodel`을 프로젝트에 추가하면  
빌드 시점에 `.mlmodelc`(컴파일된 모델)로 바꿔 번들에 넣고, 원본은 포함시키지 않는걸로 보였습니다.  
코드에서 `withExtension: "mlmodel"`로 찾고 있었으니, 번들 안에 실제로 없는 파일을 찾고 있었던 겁니다.

### 🔧 수정

`withExtension`을 `"mlmodelc"`로 고치고,  
컴파일된 모델만 읽는 `MLModel(contentsOf:)`에 맞춰 불필요한 `compileModel(at:)` 호출도 없앴습니다.
```swift
guard let bundledCompiledURL = Bundle.main.url(forResource: "CategoryClassifier", withExtension: "mlmodelc") else {
    return
}
try? fileManager.copyItem(at: bundledCompiledURL, to: writableURL)
self.model = try? MLModel(contentsOf: writableURL)
```

이제 "스타벅스"를 말하면 "기타"가 아닌 "카페/간식"으로 정확히 예측되는 걸 확인까지 완료했습니다.
