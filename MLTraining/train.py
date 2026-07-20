import json
import os
from collections import Counter

from coremltools.models import MLModel
from coremltools.models.nearest_neighbors import KNearestNeighborsClassifierBuilder

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SEED_DATA_PATH = os.path.join(SCRIPT_DIR, "seed_data.json")
VOCAB_OUTPUT_PATH = os.path.join(SCRIPT_DIR, "vocabulary.json")
MODEL_OUTPUT_PATH = os.path.join(SCRIPT_DIR, "CategoryClassifier.mlmodel")

DEFAULT_CATEGORY = "기타"

CHOSUNG = list("ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ")
JUNGSUNG = list("ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ")
JONGSUNG = [""] + list("ㄱㄲㄳㄴㄵㄶㄷㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅄㅅㅆㅇㅈㅊㅋㅌㅍㅎ")

HANGUL_BASE = 0xAC00
HANGUL_LAST = 0xD7A3

# 한글 외 문자: 숫자, 영문 대소문자, 상호명에 흔히 쓰이는 특수문자
DIGITS = list("0123456789")
ALPHA_LOWER = list("abcdefghijklmnopqrstuvwxyz")
ALPHA_UPPER = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
MISC_CHARS = [" ", "&", "+", "-", ".", ",", "'"]


def decompose_hangul(char):
    """완성형 한글 한 글자를 (초성, 중성, 종성) 튜플로 분해한다. 한글이 아니면 None."""
    code = ord(char)
    if not (HANGUL_BASE <= code <= HANGUL_LAST):
        return None
    offset = code - HANGUL_BASE
    cho = offset // (21 * 28)
    jung = (offset % (21 * 28)) // 28
    jong = offset % 28
    return (CHOSUNG[cho], JUNGSUNG[jung], JONGSUNG[jong])


def tokenize(text):
    """문자열을 자모 단위(한글은 초/중/종성으로 분해, 그 외는 원래 글자 그대로) 토큰 리스트로 변환한다."""
    tokens = []
    for char in text:
        decomposed = decompose_hangul(char)
        if decomposed:
            cho, jung, jong = decomposed
            tokens.append(cho)
            tokens.append(jung)
            if jong:
                tokens.append("_" + jong)  # 종성은 초성과 겹치지 않도록 접두어를 붙인다
        else:
            tokens.append(char)
    return tokens


def build_vocabulary():
    """이론상 가능한 전체 자모와 비한글 문자를 고정된 vocabulary로 만든다."""
    jongsung_tokens = ["_" + j for j in JONGSUNG if j]  # 종성 없음("") 제외
    tokens = CHOSUNG + JUNGSUNG + jongsung_tokens + DIGITS + ALPHA_LOWER + ALPHA_UPPER + MISC_CHARS
    return sorted(set(tokens))


def vectorize(memo, vocabulary):
    """memo 문자열을 vocabulary 기준 자모 빈도 벡터로 변환한다."""
    counts = Counter(tokenize(memo))
    return [float(counts.get(token, 0)) for token in vocabulary]


def main():
    with open(SEED_DATA_PATH, encoding="utf-8") as f:
        seed_data = json.load(f)

    memos = [item["memo"] for item in seed_data]
    labels = [item["category"] for item in seed_data]

    vocabulary = build_vocabulary()
    print(f"Vocabulary 크기: {len(vocabulary)}개 (자모/문자 단위)")

    vectors = [vectorize(memo, vocabulary) for memo in memos]

    builder = KNearestNeighborsClassifierBuilder(
        input_name="input",
        output_name="label",
        number_of_dimensions=len(vocabulary),
        default_class_label=DEFAULT_CATEGORY,
        number_of_neighbors=3,
        weighting_scheme="inverse_distance",
    )
    builder.author = "SpendLearning"
    builder.license = "Personal"
    builder.description = "음성으로 입력한 상호명을 지출 카테고리로 분류하는 kNN 모델"

    builder.add_samples(vectors, labels)

    model = MLModel(builder.spec)
    model.save(MODEL_OUTPUT_PATH)
    print(f"모델 저장 완료: {MODEL_OUTPUT_PATH}")

    with open(VOCAB_OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(vocabulary, f, ensure_ascii=False, indent=2)
    print(f"Vocabulary 저장 완료: {VOCAB_OUTPUT_PATH}")


if __name__ == "__main__":
    main()
