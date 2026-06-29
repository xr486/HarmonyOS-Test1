import { UserStore } from '../common/store/UserStore';
import { UserApi } from '../common/api/UserApi';
import { LoginRequest } from '../common/model/UserModel';
import { RouterUtil } from '../common/utils/RouterUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface LoginPageParams {
  from?: string;
  redirectUrl?: string;
  redirectParams?: Record<string, Object>;
}

@Entry
@Component
struct LoginPage {
  @State userStore: UserStore = UserStore.getInstance();
  @State loginType: string = 'password';
  @State accountType: 'student' | 'phone' = 'student';
  @State account: string = '';
  @State password: string = '';
  @State phone: string = '';
  @State code: string = '';
  @State isLoading: boolean = false;
  @State countdown: number = 0;
  @State redirectUrl: string = '';
  @State redirectParams: Record<string, Object> = {};
  private timerId: number = -1;

  aboutToAppear(): void {
    const params = router.getParams() as LoginPageParams;
    if (params) {
      if (params.redirectUrl) {
        this.redirectUrl = params.redirectUrl;
        this.redirectParams = params.redirectParams || {};
        RouterUtil.setRedirectUrl(this.redirectUrl, this.redirectParams);
      }
    }
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  get canSubmit(): boolean {
    if (this.loginType === 'password') {
      return this.account.trim().length > 0 && this.password.trim().length >= 6;
    } else {
      return this.phone.trim().length === 11 && this.code.trim().length === 6;
    }
  }

  sendCode(): void {
    if (this.phone.trim().length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }
    if (this.countdown > 0) return;

    promptAction.showToast({ message: '验证码已发送', duration: 2000 });
    this.countdown = 60;
    this.timerId = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timerId);
        this.timerId = -1;
      }
    }, 1000);
  }

  async handleLogin(): Promise<void> {
    if (this.isLoading) return;

    if (this.loginType === 'password') {
      if (!this.account.trim()) {
        promptAction.showToast({ message: '请输入学号/账号', duration: 2000 });
        return;
      }
      if (this.password.length < 6) {
        promptAction.showToast({ message: '密码至少6位', duration: 2000 });
        return;
      }
    } else {
      if (this.phone.length !== 11) {
        promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
        return;
      }
      if (this.code.length !== 6) {
        promptAction.showToast({ message: '请输入6位验证码', duration: 2000 });
        return;
      }
    }

    this.isLoading = true;
    try {
      const request: LoginRequest = new LoginRequest();
      request.loginType = this.loginType;
      if (this.loginType === 'password') {
        request.account = this.account.trim();
        request.password = this.password;
      } else {
        request.phone = this.phone.trim();
        request.code = this.code.trim();
      }

      const result = await UserApi.login(request);
      if (result.code === 200 && result.data) {
        promptAction.showToast({ message: '登录成功', duration: 2000 });
        setTimeout(async () => {
          const redirected = await RouterUtil.redirectAfterLogin();
          if (!redirected) {
            router.back();
          }
        }, 500);
      } else {
        if (result.message) {
          promptAction.showToast({ message: result.message, duration: 2000 });
        }
      }
    } catch (e) {
      console.error('[LoginPage] login error:', JSON.stringify(e));
      promptAction.showToast({ message: '登录失败，请重试', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  PasswordLoginForm() {
    Column({ space: 16 }) {
      Column({ space: 8 }) {
        Text('学号/账号')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        TextInput({ placeholder: '请输入学号或账号', text: this.account })
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.bg_color'))
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .fontSize(15)
          .onChange((value: string) => {
            this.account = value;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('密码')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.bg_color'))
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .fontSize(15)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  SmsLoginForm() {
    Column({ space: 16 }) {
      Column({ space: 8 }) {
        Text('手机号')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.bg_color'))
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .fontSize(15)
          .maxLength(11)
          .onChange((value: string) => {
            this.phone = value.replace(/\D/g, '');
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('验证码')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        Row() {
          TextInput({ placeholder: '请输入验证码', text: this.code })
            .type(InputType.Number)
            .layoutWeight(1)
            .height(48)
            .backgroundColor($r('app.color.bg_color'))
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .fontSize(15)
            .maxLength(6)
            .onChange((value: string) => {
              this.code = value.replace(/\D/g, '');
            })

          Text(this.countdown > 0 ? `${this.countdown}s后重发` : '获取验证码')
            .fontSize(13)
            .fontColor(this.countdown > 0 ? $r('app.color.text_hint') : $r('app.color.primary_color'))
            .padding({ left: 16, right: 16 })
            .height(48)
            .onClick(() => {
              this.sendCode();
            })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          Text('🎒')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('校园失物招领')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('让失物找到归途')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 60, bottom: 40 })
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Text('密码登录')
              .fontSize(16)
              .fontWeight(this.loginType === 'password' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.loginType === 'password' ? $r('app.color.primary_color') : $r('app.color.text_secondary'))
              .padding({ bottom: 8 })
              .onClick(() => {
                this.loginType = 'password';
              })

            Blank()

            Text('验证码登录')
              .fontSize(16)
              .fontWeight(this.loginType === 'sms' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.loginType === 'sms' ? $r('app.color.primary_color') : $r('app.color.text_secondary'))
              .padding({ bottom: 8 })
              .onClick(() => {
                this.loginType = 'sms';
              })
          }
          .width('100%')
          .margin({ bottom: 24 })

          if (this.loginType === 'password') {
            this.PasswordLoginForm()
          } else {
            this.SmsLoginForm()
          }

          Button(this.isLoading ? '登录中...' : '登 录')
            .width('100%')
            .height(48)
            .fontSize(16)
            .backgroundColor(this.canSubmit && !this.isLoading ? $r('app.color.primary_color') : $r('app.color.divider_color'))
            .fontColor(Color.White)
            .borderRadius(24)
            .margin({ top: 32 })
            .enabled(this.canSubmit && !this.isLoading)
            .onClick(() => {
              this.handleLogin();
            })

          Row() {
            Text('登录即表示同意')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
            Text('《用户协议》')
              .fontSize(12)
              .fontColor($r('app.color.primary_color'))
            Text('和')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
            Text('《隐私政策》')
              .fontSize(12)
              .fontColor($r('app.color.primary_color'))
          }
          .width('100%')
          .margin({ top: 20 })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.white'))
    }
    .title('登录')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}