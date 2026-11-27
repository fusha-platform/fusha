import { describe, expect, it } from 'vitest';

import { failure, success } from '../../../src/shared/kernel/result.js';

describe('Result primitives', () => {
  it('creates a success result', () => {
    expect(success(42)).toEqual({ ok: true, value: 42 });
  });

  it('creates a failure result', () => {
    const error = new Error('failure');

    expect(failure(error)).toEqual({ ok: false, error });
  });
});
