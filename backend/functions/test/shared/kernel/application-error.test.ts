import { describe, expect, it } from 'vitest';

import { ApplicationError } from '../../../src/shared/kernel/application-error.js';

describe('ApplicationError', () => {
  it('preserves transport-independent error metadata', () => {
    const error = new ApplicationError({
      code: 'example.error',
      category: 'business',
      message: 'Example failure',
    });

    expect(error).toBeInstanceOf(Error);
    expect(error.name).toBe('ApplicationError');
    expect(error.code).toBe('example.error');
    expect(error.category).toBe('business');
    expect(error.message).toBe('Example failure');
  });

  it('preserves an optional cause', () => {
    const cause = new Error('root cause');
    const error = new ApplicationError({
      code: 'example.operational',
      category: 'operational',
      message: 'Operation failed',
      cause,
    });

    expect(error.cause).toBe(cause);
  });
});
