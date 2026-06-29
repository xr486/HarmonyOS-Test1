import { UserStore } from '../common/store/UserStore';
import { UserInfo } from '../common/model/UserModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct EditProfilePage {
  @State userStore: UserStore = UserStore.getInstance();
  @State nickName: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State studentId: string = '';
  @State gender: number = 0;
  @State isLoading: boolean = false;
  @State showGenderPicker: boolean = false;

  aboutToAppear(): void {
    if (this.userStore.userInfo) {
      const info = this.userStore.userInfo;
      this.nickName = info.name;
      this.phone = info.phone;
      this.email = info.email;
      this.studentId = info.studentId;
      this.gender = info.gender;
    }
  }

  getGenderText(): string {
    switch (this.gender) {
      case 1: return '男';
      case 2: return '女';
      default: return '未知';
    }
  }

  async handleSave(): Promise<void> {
    if (this.isLoading) return;

    if (!this.nickName.trim()) {
      promptAction.showToast({ message: '请输入昵称', duration: 2000 });
      return;
    }
    if (this.nickName.trim().length > 20) {
      promptAction.showToast({ message: '昵称最多20字', duration: 2000 });
      return;
    }

    this.isLoading = true;
    try {
      const data: Partial<UserInfo> = {
        name: this.nickName.trim(),
        phone: this.phone.trim(),
        email: this.email.trim(),
        studentId: this.studentId.trim(),
        gender: this.gender
      };
      const success = await this.userStore.updateUserInfo(data);
      if (success) {
        promptAction.showToast({ message: '保存成功', duration: 2000 });
        setTimeout(() => {
          router.back();
        }, 500);
      }
    } catch (e) {
      console.error('[EditProfilePage] save error:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  GenderPickerSheet() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor($r('app.color.text_hint'))
          .onClick(() => {
            this.showGenderPicker = false;
          })
        Blank()
        Text('选择性别')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('确定')
          .fontSize(16)
          .fontColor($r('app.color.primary_color'))
          .onClick(() => {
            this.showGenderPicker = false;
          })
      }
      .width('100%')
      .padding(16)

      List() {
        ListItem() {
          Row() {
            Text('未知')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
            if (this.gender === 0) {
              Text('✓')
                .fontSize(18)
                .fontColor($r('app.color.primary_color'))
            }
          }
          .width('100%')
          .padding(16)
          .onClick(() => {
            this.gender = 0;
          })
        }
        ListItem() {
          Row() {
            Text('男')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
            if (this.gender === 1) {
              Text('✓')
                .fontSize(18)
                .fontColor($r('app.color.primary_color'))
            }
          }
          .width('100%')
          .padding(16)
          .onClick(() => {
            this.gender = 1;
          })
        }
        ListItem() {
          Row() {
            Text('女')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
            if (this.gender === 2) {
              Text('✓')
                .fontSize(18)
                .fontColor($r('app.color.primary_color'))
            }
          }
          .width('100%')
          .padding(16)
          .onClick(() => {
            this.gender = 2;
          })
        }
      }
      .width('100%')
      .divider({ strokeWidth: 1, color: $r('app.color.divider_color') })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
  }

  @Builder
  FormItem(label: string, content: string, isLast: boolean = false, onClick: () => void = () => {}) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
      Blank()
      Text(content)
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(' >')
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
        .margin({ left: 4 })
    }
    .width('100%')
    .height(52)
    .onClick(() => {
      onClick();
    })
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          Row() {
            Column() {
              Text('👤')
                .fontSize(32)
            }
            .width(64)
            .height(64)
            .backgroundColor($r('app.color.primary_light'))
            .borderRadius(32)
            .justifyContent(FlexAlign.Center)
            .margin({ right: 16 })

            Column() {
              Text('点击更换头像')
                .fontSize(15)
                .fontColor($r('app.color.primary_color'))
              Text('支持 jpg、png 格式')
                .fontSize(12)
                .fontColor($r('app.color.text_hint'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .margin({ top: 10 })

        Column() {
          Column({ space: 0 }) {
            Row() {
              Text('昵称')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(80)
              TextInput({ placeholder: '请输入昵称', text: this.nickName })
                .layoutWeight(1)
                .height(52)
                .backgroundColor(Color.Transparent)
                .fontSize(15)
                .textAlign(TextAlign.End)
                .maxLength(20)
                .onChange((value: string) => {
                  this.nickName = value;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Divider()
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })

            Row() {
              Text('性别')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(80)
              Blank()
              Text(this.getGenderText())
                .fontSize(15)
                .fontColor($r('app.color.text_secondary'))
              Text(' >')
                .fontSize(14)
                .fontColor($r('app.color.text_hint'))
                .margin({ left: 4 })
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.showGenderPicker = true;
            })

            Divider()
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })

            Row() {
              Text('学号')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(80)
              TextInput({ placeholder: '请输入学号', text: this.studentId })
                .layoutWeight(1)
                .height(52)
                .backgroundColor(Color.Transparent)
                .fontSize(15)
                .textAlign(TextAlign.End)
                .onChange((value: string) => {
                  this.studentId = value;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Divider()
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })

            Row() {
              Text('手机号')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(80)
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .layoutWeight(1)
                .height(52)
                .backgroundColor(Color.Transparent)
                .fontSize(15)
                .textAlign(TextAlign.End)
                .maxLength(11)
                .onChange((value: string) => {
                  this.phone = value.replace(/\D/g, '');
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Divider()
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })

            Row() {
              Text('邮箱')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .width(80)
              TextInput({ placeholder: '请输入邮箱', text: this.email })
                .layoutWeight(1)
                .height(52)
                .backgroundColor(Color.Transparent)
                .fontSize(15)
                .textAlign(TextAlign.End)
                .onChange((value: string) => {
                  this.email = value;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .backgroundColor($r('app.color.white'))
        }
        .width('100%')
        .margin({ top: 10 })

        Button(this.isLoading ? '保存中...' : '保存')
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor(!this.isLoading ? $r('app.color.primary_color') : $r('app.color.divider_color'))
          .fontColor(Color.White)
          .borderRadius(24)
          .margin({ top: 40 })
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleSave();
          })

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg_color'))
    }
    .title('编辑资料')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .bindSheet($$this.showGenderPicker, this.GenderPickerSheet(), {
      height: 260,
      onDisappear: () => {
        this.showGenderPicker = false;
      }
    })
  }
}
