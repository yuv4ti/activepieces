/// <reference types='vitest' />
import { defineConfig } from 'vite';
import { createHtmlPlugin } from 'vite-plugin-html';
import react from '@vitejs/plugin-react';
import checker from 'vite-plugin-checker';
import path from 'path';
import fs from 'fs';

import { nxViteTsPaths } from '@nx/vite/plugins/nx-tsconfig-paths.plugin';

export default defineConfig(({ command, mode }) => {
  // Load environment variables from .env file
  let envVars: Record<string, string> = {};
  try {
    const envPath = path.resolve(process.cwd(), '.env');
    if (fs.existsSync(envPath)) {
      const envContent = fs.readFileSync(envPath, 'utf8');
      envVars = envContent.split('\n').reduce((acc, line) => {
        const [key, ...values] = line.split('=');
        if (key && values.length) {
          acc[key] = values.join('=').replace(/"/g, '');
        }
        return acc;
      }, {} as Record<string, string>);
    }
  } catch (error) {
    console.warn('Could not load .env file:', error);
  }

  // Use environment variables with fallbacks
  const AP_TITLE = envVars.AP_APP_TITLE || 'Activepiejjces';
  const AP_FAVICON = envVars.AP_FAVICON_URL || 'https://activepieces.com/favicon.ico';
  const AP_BRAND_NAME = envVars.AP_BRAND_NAME || 'activepieces';

  return {
    root: __dirname,
    cacheDir: '../../node_modules/.vite/packages/react-ui',

    server: {
      proxy: {
        '/api': {
          target: 'http://127.0.0.1:3000',
          secure: false,
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
          headers: {
            Host: '127.0.0.1:4200',
          },
          ws: true,
        },
      },
      port: 4200,
      host: '0.0.0.0',
    },

    preview: {
      port: 4300,
      host: 'localhost',
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@activepieces/shared': path.resolve(
          __dirname,
          '../../packages/shared/src',
        ),
        'ee-embed-sdk': path.resolve(
          __dirname,
          '../../packages/ee/ui/embed-sdk/src',
        ),
        '@activepieces/ee-shared': path.resolve(
          __dirname,
          '../../packages/ee/shared/src',
        ),
        '@activepieces/pieces-framework': path.resolve(
          __dirname,
          '../../packages/pieces/community/framework/src',
        ),
      },
    },
    plugins: [
      react(),
      nxViteTsPaths(),

      createHtmlPlugin({
        inject: {
          data: {
            apTitle: AP_TITLE,
            apFavicon: AP_FAVICON,
            apBrandName: AP_BRAND_NAME,
          },
        },
      }),
      checker({
        typescript: {
          buildMode: true,
          tsconfigPath: './tsconfig.json',
          root: __dirname,
        },
      }),
    ],

    build: {
      outDir: '../../dist/packages/react-ui',
      emptyOutDir: true,
      reportCompressedSize: true,
      commonjsOptions: {
        transformMixedEsModules: true,
      },
      rollupOptions: {
        onLog(level, log, handler) {
          if (
            log.cause &&
            log.message.includes(`Can't resolve original location of error.`)
          ) {
            return;
          }
          handler(level, log);
        },
      },
    },
  };
});
