// Validation Constants
export const VALIDATION_RULES = {
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PASSWORD_MIN_LENGTH: 8,
  USERNAME_MIN_LENGTH: 3,
  USERNAME_MAX_LENGTH: 30,
} as const;

export const VALIDATION_MESSAGES = {
  REQUIRED: 'This field is required',
  INVALID_EMAIL: 'Please enter a valid email address',
  PASSWORD_TOO_SHORT: `Password must be at least ${VALIDATION_RULES.PASSWORD_MIN_LENGTH} characters long`,
  USERNAME_TOO_SHORT: `Username must be at least ${VALIDATION_RULES.USERNAME_MIN_LENGTH} characters long`,
  USERNAME_TOO_LONG: `Username must not exceed ${VALIDATION_RULES.USERNAME_MAX_LENGTH} characters`,
  PASSWORDS_DONT_MATCH: 'Passwords do not match',
} as const;