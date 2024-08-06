const VALID_PIN_REGEX = /^\d{4,12}$/;

export const validatePin = (pin: string) => {
  if (!VALID_PIN_REGEX.test(pin)) {
    throw new Error('Invalid PIN, must be string of 4-12 decimal digits');
  }
};

export const VALID_WORD_COUNTS = [12, 15, 18, 21, 24, 1000];

export const validateWordCount = (wordCount: number) => {
  if (!VALID_WORD_COUNTS.includes(wordCount)) {
    throw new Error(
      `Invalid word count, must be one of [${VALID_WORD_COUNTS.join(', ')}]`
    );
  }
};
