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


def build_vocabulary(memos):
    """시드 데이터에 등장하는 모든 글자를 모아 정렬된 vocabulary를 만든다."""
    chars = set()
    for memo in memos:
        chars.update(memo)
    return sorted(chars)


def vectorize(memo, vocabulary):
    """memo 문자열을 vocabulary 기준 글자 빈도 벡터로 변환한다."""
    counts = Counter(memo)
    return [float(counts.get(ch, 0)) for ch in vocabulary]


def main():
    with open(SEED_DATA_PATH, encoding="utf-8") as f:
        seed_data = json.load(f)

    memos = [item["memo"] for item in seed_data]
    labels = [item["category"] for item in seed_data]

    vocabulary = build_vocabulary(memos)
    print(f"Vocabulary 크기: {len(vocabulary)}자")

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
