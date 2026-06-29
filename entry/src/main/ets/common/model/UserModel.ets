export class UserInfo {
  id: string = '';
  name: string = '';
  avatar: string = '';
  phone: string = '';
  studentId: string = '';
  email: string = '';
  gender: number = 0;
  createTime: number = 0;
  lastLoginTime: number = 0;
  status: number = 0;
}

export class LoginResult {
  token: string = '';
  expireTime: number = 0;
  userInfo: UserInfo = new UserInfo();
}

export class LoginRequest {
  loginType: string = 'password';
  account: string = '';
  password: string = '';
  phone: string = '';
  code: string = '';
}

export class UpdatePasswordRequest {
  oldPassword: string = '';
  newPassword: string = '';
}
