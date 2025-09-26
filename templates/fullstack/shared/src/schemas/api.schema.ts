// API validation schemas
export const paginationSchema = {
  type: 'object',
  properties: {
    page: {
      type: 'integer',
      minimum: 1,
      default: 1,
      errorMessage: 'Page must be a positive integer'
    },
    limit: {
      type: 'integer',
      minimum: 1,
      maximum: 100,
      default: 10,
      errorMessage: 'Limit must be between 1 and 100'
    },
    sort: {
      type: 'string',
      errorMessage: 'Sort must be a string'
    },
    order: {
      type: 'string',
      enum: ['asc', 'desc'],
      default: 'asc',
      errorMessage: 'Order must be asc or desc'
    }
  },
  additionalProperties: false
};

export const searchSchema = {
  type: 'object',
  properties: {
    query: {
      type: 'string',
      minLength: 1,
      errorMessage: 'Search query must not be empty'
    },
    fields: {
      type: 'array',
      items: { type: 'string' },
      errorMessage: 'Fields must be an array of strings'
    },
    caseSensitive: {
      type: 'boolean',
      default: false
    },
    regex: {
      type: 'boolean',
      default: false
    }
  },
  required: ['query'],
  additionalProperties: false
};