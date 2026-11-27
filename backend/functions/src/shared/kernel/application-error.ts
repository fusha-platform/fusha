export type ApplicationErrorCategory = 'request' | 'business' | 'operational';

export type ApplicationErrorOptions = Readonly<{
  code: string;
  category: ApplicationErrorCategory;
  message: string;
  cause?: unknown;
}>;

/**
 * Transport-independent application error.
 * Stable code ownership and the public error catalogue remain with the API contract.
 */
export class ApplicationError extends Error {
  public readonly code: string;
  public readonly category: ApplicationErrorCategory;

  public constructor(options: ApplicationErrorOptions) {
    super(options.message, options.cause === undefined ? undefined : { cause: options.cause });

    this.name = 'ApplicationError';
    this.code = options.code;
    this.category = options.category;
  }
}
