import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { LostFoundItem, ItemStatus, formatTime, getStatusText } from '../common/bean/LostFoundItem';
import { UserInfo } from '../common/bean/UserInfo';
import router from '@ohos.router';

@Component
export struct ProfileContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  onGoPublish: () => void = () => {};

  handleLogin() {
    if (!this.viewModel.isLoggedIn()) {
      const user: UserInfo = new UserInfo();
      user.id = 'user_' + Date.now();
      user.name = '校园用户';
      this.viewModel.login(user);
    }
  }

  handleLogout() {
    this.viewModel.logout();
  }

  @Builder
  MyItemCard(item: LostFoundItem) {
    Row() {
      Column() {
        Text('📷')
          .fontSize(28)
      }
      .width(60)
      .height(60)
      .backgroundColor($r('app.color.bg_color'))
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      Column() {
        Row() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Text(getStatusText(item.status, item.type))
            .fontSize(11)
            .fontColor(item.status === ItemStatus.ACTIVE ? $r('app.color.status_active_text') : $r('app.color.status_done_text'))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(item.status === ItemStatus.ACTIVE ? $r('app.color.status_active_bg') : $r('app.color.status_done_bg'))
            .borderRadius(4)
        }
        .width('100%')

        Text(item.description)
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 6 })

        Row() {
          Text(formatTime(item.publishTime))
            .fontSize(11)
            .fontColor($r('app.color.text_hint'))

          Blank()

          if (item.status === ItemStatus.ACTIVE) {
            Text('标记完成')
              .fontSize(12)
              .fontColor($r('app.color.primary_color'))
              .margin({ left: 12 })
              .onClick(() => {
                this.viewModel.markAsResolved(item.id);
              })
            Text('下架')
              .fontSize(12)
              .fontColor($r('app.color.lost_color'))
              .margin({ left: 12 })
              .onClick(() => {
                this.viewModel.removeItem(item.id);
              })
          }
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ bottom: 10 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: { id: item.id }
      });
    })
  }

  build() {
    Column() {
      Column() {
        Column() {
          Text('👤')
            .fontSize(48)
        }
        .width(80)
        .height(80)
        .backgroundColor($r('app.color.primary_light'))
        .borderRadius(40)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 12 })

        if (this.viewModel.isLoggedIn()) {
          Text(this.viewModel.currentUser!.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 6 })
          Text('欢迎使用校园失物招领')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
            .margin({ bottom: 16 })
          Button('退出登录')
            .fontSize(13)
            .height(32)
            .backgroundColor($r('app.color.bg_color'))
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              this.handleLogout();
            })
        } else {
          Text('点击登录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 6 })
            .onClick(() => {
              this.handleLogin();
            })
          Text('登录后可发布和管理信息')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))
            .margin({ bottom: 16 })
        }
      }
      .width('100%')
      .padding({ top: 30, bottom: 20 })
      .backgroundColor($r('app.color.white'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Row() {
        Column() {
          Text(this.viewModel.isLoggedIn() ? this.viewModel.getMyPublishedItems().filter((i: LostFoundItem) => i.status === ItemStatus.ACTIVE).length.toString() : '0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('进行中')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.viewModel.isLoggedIn() ? this.viewModel.getMyPublishedItems().filter((i: LostFoundItem) => i.status !== ItemStatus.ACTIVE).length.toString() : '0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('已完成')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.viewModel.isLoggedIn() ? this.viewModel.getMyPublishedItems().length.toString() : '0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('总发布')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .backgroundColor($r('app.color.white'))
      .margin({ top: 1 })

      Row() {
        Text('我的发布')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding(16)

      if (!this.viewModel.isLoggedIn()) {
        Column() {
          Text('🔒')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('请先登录查看发布记录')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .padding({ top: 60 })
      } else if (this.viewModel.getMyPublishedItems().length === 0) {
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无发布记录')
            .fontSize(14)
            .fontColor($r('app.color.text_hint'))
          Button('去发布')
            .fontSize(14)
            .height(36)
            .margin({ top: 16 })
            .backgroundColor($r('app.color.primary_color'))
            .onClick(() => {
              this.onGoPublish();
            })
        }
        .width('100%')
        .padding({ top: 60 })
      } else {
        Scroll() {
          Column() {
            ForEach(this.viewModel.getMyPublishedItems(), (item: LostFoundItem) => {
              this.MyItemCard(item)
            }, (item: LostFoundItem) => item.id)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
  }
}
