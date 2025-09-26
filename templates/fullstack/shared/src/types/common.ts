// Common types
export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface QueryOptions {
  select?: string[];
  populate?: string[];
  lean?: boolean;
}

export interface SearchOptions {
  query?: string;
  fields?: string[];
  caseSensitive?: boolean;
  regex?: boolean;
}

export type SortOrder = 'asc' | 'desc' | 1 | -1;

export interface SortOptions {
  [key: string]: SortOrder;
}