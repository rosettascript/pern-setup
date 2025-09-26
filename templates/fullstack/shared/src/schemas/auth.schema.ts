// Auth validation schemas
export const loginSchema = {
  type: 'object',
  properties: {
    email: {
      type: 'string',
      format: 'email',
      minLength: 1,
      errorMessage: 'Valid email is required'
    },
    password: {
      type: 'string',
      minLength: 1,
      errorMessage: 'Password is required'
    }
  },
  required: ['email', 'password'],
  additionalProperties: false
};

export const registerSchema = {
  type: 'object',
  properties: {
    email: {
      type: 'string',
      format: 'email',
      minLength: 1,
      errorMessage: 'Valid email is required'
    },
    password: {
      type: 'string',
      minLength: 8,
      errorMessage: 'Password must be at least 8 characters long'
    },
    username: {
      type: 'string',
      minLength: 3,
      maxLength: 30,
      pattern: '^[a-zA-Z0-9_]+$',
      errorMessage: 'Username must be 3-30 characters and contain only letters, numbers, and underscores'
    }
  },
  required: ['email', 'password', 'username'],
  additionalProperties: false
};