import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME = 'campus_lostandfound_prefs';
const KEY_TOKEN = 'auth_token';
const KEY_TOKEN_EXPIRE = 'token_expire_time';

export class TokenUtil {
  private static instance: TokenUtil | null = null;
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  public static getInstance(): TokenUtil {
    if (!TokenUtil.instance) {
      TokenUtil.instance = new TokenUtil();
    }
    return TokenUtil.instance;
  }

  init(context: common.UIAbilityContext): void {
    if (this.preferences) {
      return;
    }
    this.context = context;
    try {
      this.preferences = preferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
    } catch (e) {
      console.error('[TokenUtil] init preferences failed:', JSON.stringify(e));
    }
  }

  private checkPrefs(): boolean {
    if (!this.preferences) {
      console.error('[TokenUtil] preferences not initialized');
      return false;
    }
    return true;
  }

  saveToken(token: string, expireTime: number): void {
    if (!this.checkPrefs()) return;
    try {
      this.preferences!.putSync(KEY_TOKEN, token);
      this.preferences!.putSync(KEY_TOKEN_EXPIRE, expireTime.toString());
      this.preferences!.flush();
    } catch (e) {
      console.error('[TokenUtil] saveToken failed:', JSON.stringify(e));
    }
  }

  getToken(): string {
    if (!this.checkPrefs()) return '';
    try {
      return this.preferences!.getSync(KEY_TOKEN, '') as string;
    } catch (e) {
      console.error('[TokenUtil] getToken failed:', JSON.stringify(e));
      return '';
    }
  }

  getExpireTime(): number {
    if (!this.checkPrefs()) return 0;
    try {
      const val = this.preferences!.getSync(KEY_TOKEN_EXPIRE, '0') as string;
      return parseInt(val, 10) || 0;
    } catch (e) {
      console.error('[TokenUtil] getExpireTime failed:', JSON.stringify(e));
      return 0;
    }
  }

  isTokenValid(): boolean {
    const token = this.getToken();
    if (!token) return false;
    const expireTime = this.getExpireTime();
    if (expireTime === 0) return true;
    return Date.now() < expireTime;
  }

  clearToken(): void {
    if (!this.checkPrefs()) return;
    try {
      this.preferences!.deleteSync(KEY_TOKEN);
      this.preferences!.deleteSync(KEY_TOKEN_EXPIRE);
      this.preferences!.flush();
    } catch (e) {
      console.error('[TokenUtil] clearToken failed:', JSON.stringify(e));
    }
  }
}
