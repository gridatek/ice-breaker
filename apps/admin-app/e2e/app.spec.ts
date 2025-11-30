import { test, expect } from '@playwright/test';

test.describe('Admin App', () => {
  test('should load the home page', async ({ page }) => {
    await page.goto('/');

    // Wait for Angular to load
    await page.waitForLoadState('networkidle');

    // Check that the page loaded successfully
    expect(await page.title()).toBeTruthy();
  });

  test('should display the app component', async ({ page }) => {
    await page.goto('/');

    // Wait for the app component to be present
    const appComponent = page.locator('app-root');
    await expect(appComponent).toBeVisible();
  });
});
