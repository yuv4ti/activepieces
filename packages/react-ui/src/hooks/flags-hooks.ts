import { useSuspenseQuery } from '@tanstack/react-query';

import { ApFlagId } from '@activepieces/shared';

import { flagsApi, FlagsMap } from '../lib/flags-api';

type WebsiteBrand = {
  websiteName: string;
  logos: {
    fullLogoUrl: string;
    favIconUrl: string;
    logoIconUrl: string;
  };
  colors: {
    primary: {
      default: string;
      dark: string;
      light: string;
    };
  };
};
const queryKey = ['flags'];
export const flagsHooks = {
  queryKey,
  useFlags: () => {
    return useSuspenseQuery<FlagsMap, Error>({
      queryKey,
      queryFn: flagsApi.getAll,
      staleTime: Infinity,
    });
  },
  useWebsiteBranding: () => {
    const { data: theme } = flagsHooks.useFlag<WebsiteBrand>(ApFlagId.THEME);

    // Use environment-based branding as fallback or override
    const envBrandName = (window as any).apBrandName;
    const envFavIcon = (window as any).apFavicon;

    return {
      websiteName: envBrandName || theme?.websiteName || 'Activepieces',
      logos: {
        fullLogoUrl: envFavIcon || theme?.logos?.fullLogoUrl || '/assets/ap-logo.png',
        favIconUrl: envFavIcon || theme?.logos?.favIconUrl || envFavIcon,
        logoIconUrl: theme?.logos?.logoIconUrl || '/assets/ap-logo.png',
      },
      colors: theme?.colors || {
        primary: {
          default: '#8B5CF6',
          dark: '#7C3AED',
          light: '#A78BFA',
        },
      },
    };
  },
  useFlag: <T>(flagId: ApFlagId) => {
    const data = useSuspenseQuery<FlagsMap, Error>({
      queryKey: ['flags'],
      queryFn: flagsApi.getAll,
      staleTime: Infinity,
    }).data?.[flagId] as T | null;
    return {
      data,
    };
  },
};
