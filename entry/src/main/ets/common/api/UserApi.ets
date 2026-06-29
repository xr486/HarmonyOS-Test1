import { HttpUtil } from './HttpUtil';
import { ApiResult } from '../model/ApiResult';
import { LoginRequest, LoginResult, UserInfo } from '../model/UserModel';

export class UserApi {
  private static http = HttpUtil.getInstance();

  static login(request: LoginRequest): Promise<ApiResult<LoginResult>> {
    return this.http.post<LoginResult>('/auth/login', request, false);
  }

  static getUserInfo(): Promise<ApiResult<UserInfo>> {
    return this.http.get<UserInfo>('/user/info', undefined, true);
  }

  static updateUserInfo(data: Partial<UserInfo>): Promise<ApiResult<null>> {
    return this.http.put<null>('/user/info', data, true);
  }

  static updatePassword(oldPassword: string, newPassword: string): Promise<ApiResult<null>> {
    return this.http.put<null>('/user/password', {
      oldPassword,
      newPassword
    }, true);
  }
}
