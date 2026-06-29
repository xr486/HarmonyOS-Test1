import router from '@ohos.router';
import { UserStore } from '../store/UserStore';

/**
 * 路由工具类
 * 支持路由守卫、登录跳转、返回原页面等功能
 */
export class RouterUtil {
  private static userStore: UserStore = UserStore.getInstance();
  private static redirectUrl: string = '';
  private static redirectParams: Record<string, Object> = {};

  /**
   * 需要登录才能访问的页面路径列表
   */
  private static authRequiredPages: string[] = [
    'pages/EditProfilePage',
    'pages/EditPage',
    'pages/PublishPage'
  ];

  /**
   * 检查页面是否需要登录
   */
  static isAuthRequired(url: string): boolean {
    const pages = RouterUtil.authRequiredPages;
    for (let i = 0; i < pages.length; i++) {
      if (url.includes(pages[i])) {
        return true;
      }
    }
    return false;
  }

  /**
   * 跳转到指定页面（带登录校验）
   * @param url 目标页面
   * @param params 页面参数
   * @param requireLogin 是否需要登录
   * @returns 是否成功跳转
   */
  static async navigateTo(
    url: string,
    params?: Record<string, Object>,
    requireLogin: boolean = false
  ): Promise<boolean> {
    const needLogin = requireLogin || RouterUtil.isAuthRequired(url);
    const userStore = RouterUtil.userStore;

    if (needLogin && !userStore.isLoggedIn) {
      RouterUtil.redirectUrl = url;
      RouterUtil.redirectParams = params || {};
      try {
        const redirectParams: Record<string, Object> = {
          'from': 'guard',
          'redirectUrl': url,
          'redirectParams': params || {}
        };
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

  /**
   * 登录成功后跳转
   * @returns 是否跳转到了原页面
   */
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

  /**
   * 保存重定向URL（登录页手动调用）
   */
  static setRedirectUrl(url: string, params: Record<string, Object> = {}): void {
    RouterUtil.redirectUrl = url;
    RouterUtil.redirectParams = params;
  }

  /**
   * 清除重定向URL
   */
  static clearRedirectUrl(): void {
    RouterUtil.redirectUrl = '';
    RouterUtil.redirectParams = {};
  }

  /**
   * 返回上一页
   */
  static back(): void {
    try {
      router.back();
    } catch (e) {
      console.error('[RouterUtil] back error:', JSON.stringify(e));
    }
  }

  /**
   * 跳转到首页
   */
  static goHome(): void {
    try {
      router.replaceUrl({ url: 'pages/Index' });
    } catch (e) {
      console.error('[RouterUtil] goHome error:', JSON.stringify(e));
    }
  }

  /**
   * 添加需要登录的页面
   */
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
