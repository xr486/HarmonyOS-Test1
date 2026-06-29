import router from '@ohos.router';
import { UserStore } from '../store/UserStore';

export class RouterParams {
  from: string = '';
  redirectUrl: string = '';
}

export class RouterUtil {
  private static userStore: UserStore = UserStore.getInstance();
  private static redirectUrl: string = '';
  private static redirectParams: Record<string, Object> = {};

  private static authRequiredPages: string[] = [
    'pages/EditProfilePage',
    'pages/EditPage',
    'pages/PublishPage'
  ];

  static isAuthRequired(url: string): boolean {
    const pages = RouterUtil.authRequiredPages;
    for (let i = 0; i < pages.length; i++) {
      if (url.includes(pages[i])) {
        return true;
      }
    }
    return false;
  }

  static async navigateTo(
    url: string,
    params?: Record<string, Object>,
    requireLogin: boolean = false
  ): Promise<boolean> {
    const needLogin = requireLogin || RouterUtil.isAuthRequired(url);
    const userStore = RouterUtil.userStore;

    if (needLogin && !userStore.isLoggedIn) {
      RouterUtil.redirectUrl = url;
      if (params) {
        RouterUtil.redirectParams = params;
      }
      try {
        const redirectParams: RouterParams = new RouterParams();
        redirectParams.from = 'guard';
        redirectParams.redirectUrl = url;
        await router.pushUrl({
          url: 'pages/LoginPage',
          params: redirectParams
        });
        return false;
      } catch (e) {
        console.error('[RouterUtil] navigate to login error:', JSON.stringify(e));
        return false;
      }
    }

    try {
      await router.pushUrl({
        url: url,
        params: params
      });
      return true;
    } catch (e) {
      console.error('[RouterUtil] navigate error:', JSON.stringify(e));
      return false;
    }
  }

  static async redirectAfterLogin(): Promise<boolean> {
    if (RouterUtil.redirectUrl) {
      const url = RouterUtil.redirectUrl;
      const params = RouterUtil.redirectParams;
      RouterUtil.redirectUrl = '';
      RouterUtil.redirectParams = {};
      try {
        await router.replaceUrl({
          url: url,
          params: params
        });
        return true;
      } catch (e) {
        console.error('[RouterUtil] redirectAfterLogin error:', JSON.stringify(e));
        return false;
      }
    }
    return false;
  }

  static setRedirectUrl(url: string, params: Record<string, Object> = {}): void {
    RouterUtil.redirectUrl = url;
    RouterUtil.redirectParams = params;
  }

  static clearRedirectUrl(): void {
    RouterUtil.redirectUrl = '';
    RouterUtil.redirectParams = {};
  }

  static back(): void {
    try {
      router.back();
    } catch (e) {
      console.error('[RouterUtil] back error:', JSON.stringify(e));
    }
  }

  static goHome(): void {
    try {
      router.replaceUrl({ url: 'pages/Index' });
    } catch (e) {
      console.error('[RouterUtil] goHome error:', JSON.stringify(e));
    }
  }

  static addAuthPage(page: string): void {
    const pages = RouterUtil.authRequiredPages;
    let found = false;
    for (let i = 0; i < pages.length; i++) {
      if (pages[i] === page) {
        found = true;
        break;
      }
    }
    if (!found) {
      pages.push(page);
    }
  }
}
