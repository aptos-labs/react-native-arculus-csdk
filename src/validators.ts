const VALID_PIN_REGEX = /^\d{4,12}$/;

export const validatePin = (pin: string) => {
  if (!VALID_PIN_REGEX.test(pin)) {
    throw new Error('Invalid pin, must be string of 4-12 decimal digits');
  }
};
