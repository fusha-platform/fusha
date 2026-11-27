import { getApp, getApps, initializeApp, type App } from 'firebase-admin/app';

let cachedDefaultApp: App | undefined;

/**
 * Initializes the trusted Firebase Admin app lazily and at most once per process.
 * Importing this module has no initialization side effects.
 */
export function getAdminApp(): App {
  if (cachedDefaultApp !== undefined) {
    return cachedDefaultApp;
  }

  const defaultAppExists = getApps().some((app) => app.name === '[DEFAULT]');
  cachedDefaultApp = defaultAppExists ? getApp() : initializeApp();

  return cachedDefaultApp;
}
