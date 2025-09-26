// Validation utilities
import { VALIDATION_RULES, VALIDATION_MESSAGES } from '../constants/validation.constants';

export const validateEmail = (email: string): boolean => {
  return VALIDATION_RULES.EMAIL_REGEX.test(email);
};

export const validatePassword = (password: string): { isValid: boolean; message?: string } => {
  if (password.length < VALIDATION_RULES.PASSWORD_MIN_LENGTH) {
    return {
      isValid: false,
      message: VALIDATION_MESSAGES.PASSWORD_TOO_SHORT
    };
  }
  return { isValid: true };
};

export const validateUsername = (username: string): { isValid: boolean; message?: string } => {
  if (username.length < VALIDATION_RULES.USERNAME_MIN_LENGTH) {
    return {
      isValid: false,
      message: VALIDATION_MESSAGES.USERNAME_TOO_SHORT
    };
  }
  if (username.length > VALIDATION_RULES.USERNAME_MAX_LENGTH) {
    return {
      isValid: false,
      message: VALIDATION_MESSAGES.USERNAME_TOO_LONG
    };
  }
  return { isValid: true };
};

export const sanitizeInput = (input: string): string => {
  return input.trim().replace(/[<>]/g, '');
};