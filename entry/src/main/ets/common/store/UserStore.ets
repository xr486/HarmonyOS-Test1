import { UserInfo, LoginRequest, LoginResult } from '../model/UserModel';
import { UserApi } from '../api/UserApi';
import { TokenUtil } from '../utils/TokenUtil';

@Observed
export class UserStore {
  private static instance: UserStore | null = null;
  userInfo: UserInfo | null = null;
  isLoggedIn: boolean = false;
  isLoading: boolean = false;

  private constructor() {}

  public static getInstance(): UserStore {
    if (!UserStore.instance) {
      UserStore.instance = new UserStore();
    }
    return UserStore.instance;
  }

  init(): void {
    const tokenUtil = TokenUtil.getInstance();
    const tokenValid = tokenUtil.isTokenValid();
    if (tokenValid) {
      this.isLoggedIn = true;
      this.loadUserInfo();
    } else {
      this.isLoggedIn = false;
      this.userInfo = null;
    }
  }

  async login(request: LoginRequest): Promise<boolean> {
    this.isLoading = true;
    try {
      const result = await UserApi.login(request);
      if (result.code === 200 && result.data) {
        const loginData = result.data as LoginResult;
        const tokenUtil = TokenUtil.getInstance();
        tokenUtil.saveToken(loginData.token, loginData.expireTime);
        this.userInfo = loginData.userInfo;
        this.isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      console.error('[UserStore] login error:', JSON.stringify(e));
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  async loadUserInfo(): Promise<boolean> {
    try {
      const result = await UserApi.getUserInfo();
      if (result.code === 200 && result.data) {
        this.userInfo = result.data as UserInfo;
        this.isLoggedIn = true;
        return true;
      } else if (result.code === 401) {
        this.logout();
        return false;
      }
      return false;
    } catch (e) {
      console.error('[UserStore] loadUserInfo error:', JSON.stringify(e));
      return false;
    }
  }

  async updateUserInfo(data: Partial<UserInfo>): Promise<boolean> {
    try {
      const result = await UserApi.updateUserInfo(data);
      if (result.code === 200) {
        if (this.userInfo) {
          // 手动复制属性而不是使用 Object.assign
          if (data.name !== undefined) {
            this.userInfo.name = data.name;
          }
          if (data.avatar !== undefined) {
            this.userInfo.avatar = data.avatar;
          }
          if (data.phone !== undefined) {
            this.userInfo.phone = data.phone;
          }
          if (data.studentId !== undefined) {
            this.userInfo.studentId = data.studentId;
          }
          if (data.email !== undefined) {
            this.userInfo.email = data.email;
          }
          if (data.gender !== undefined) {
            this.userInfo.gender = data.gender;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      console.error('[UserStore] updateUserInfo error:', JSON.stringify(e));
      return false;
    }
  }

  logout(): void {
    const tokenUtil = TokenUtil.getInstance();
    tokenUtil.clearToken();
    this.userInfo = null;
    this.isLoggedIn = false;
  }

  checkLogin(): boolean {
    if (!this.isLoggedIn) {
      const tokenUtil = TokenUtil.getInstance();
      return tokenUtil.isTokenValid();
    }
    return this.isLoggedIn;
  }

  getToken(): string {
    const tokenUtil = TokenUtil.getInstance();
    return tokenUtil.getToken() || '';
  }

  getUserInfo(): UserInfo | null {
    return this.userInfo;
  }
}
