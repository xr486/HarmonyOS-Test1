import { HttpUtil } from './HttpUtil';
import { ApiResult } from '../model/ApiResult';
import { LoginRequest, LoginResult, UserInfo } from '../model/UserModel';

export class UserApi {
  static login(request: LoginRequest): Promise<ApiResult<LoginResult>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.post<LoginResult>('/auth/login', request, false);
  }

  static getUserInfo(): Promise<ApiResult<UserInfo>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.get<UserInfo>('/user/info', undefined, true);
  }

  static updateUserInfo(data: Partial<UserInfo>): Promise<ApiResult<Object>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.put<Object>('/user/info', data, true);
  }

  static updatePassword(oldPassword: string, newPassword: string): Promise<ApiResult<Object>> {
    const http: HttpUtil = HttpUtil.getInstance();
    const request: Record<string, string> = {
      oldPassword: oldPassword,
      newPassword: newPassword
    };
    return http.put<Object>('/user/password', request, true);
  }
}
