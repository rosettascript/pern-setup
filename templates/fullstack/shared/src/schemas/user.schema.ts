// User validation schemas
export const userProfileSchema = {
  type: 'object',
  properties: {
    firstName: {
      type: 'string',
      minLength: 1,
      maxLength: 50,
      errorMessage: 'First name must be 1-50 characters'
    },
    lastName: {
      type: 'string',
      minLength: 1,
      maxLength: 50,
      errorMessage: 'Last name must be 1-50 characters'
    },
    bio: {
      type: 'string',
      maxLength: 500,
      errorMessage: 'Bio must not exceed 500 characters'
    },
    phone: {
      type: 'string',
      pattern: '^\\+?[1-9]\\d{1,14}$',
      errorMessage: 'Please enter a valid phone number'
    }
  },
  additionalProperties: false
};

export const userPreferencesSchema = {
  type: 'object',
  properties: {
    theme: {
      type: 'string',
      enum: ['light', 'dark', 'auto'],
      errorMessage: 'Theme must be light, dark, or auto'
    },
    language: {
      type: 'string',
      minLength: 2,
      maxLength: 5,
      errorMessage: 'Language must be 2-5 characters'
    },
    notifications: {
      type: 'object',
      properties: {
        email: { type: 'boolean' },
        push: { type: 'boolean' },
        sms: { type: 'boolean' }
      },
      additionalProperties: false
    }
  },
  required: ['theme', 'language'],
  additionalProperties: false
};