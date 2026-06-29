import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { LostFoundItem, ItemType, ItemStatus, formatTime, getStatusText, getCategoryName } from '../common/bean/LostFoundItem';
import router from '@ohos.router';

interface DetailPageParams {
  id: string;
}

@Entry
@Component
struct DetailPage {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State itemId: string = '';
  @State item: LostFoundItem = new LostFoundItem();
  @State hasItem: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as DetailPageParams;
    if (params && params.id) {
      this.itemId = params.id;
      const found = this.viewModel.getItemById(this.itemId);
      if (found) {
        this.item = found;
        this.hasItem = true;
      }
    }
  }

  build() {
    Navigation() {
      if (this.hasItem) {
        Scroll() {
          Column() {
            Stack() {
              Column() {
                Text('📷')
                  .fontSize(64)
              }
              .width('100%')
              .height(240)
              .backgroundColor($r('app.color.primary_light'))
              .justifyContent(FlexAlign.Center)

              Row() {
                Text(this.item.type === ItemType.LOST ? '寻物启事' : '失物招领')
                  .fontSize(13)
                  .fontColor(Color.White)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.item.type === ItemType.LOST ? $r('app.color.lost_color') : $r('app.color.found_color'))
                  .borderRadius(4)
                  .margin({ right: 8 })

                Text(getStatusText(this.item.status, this.item.type))
                  .fontSize(12)
                  .fontColor(this.item.status === ItemStatus.ACTIVE ? $r('app.color.status_active_text') : $r('app.color.status_done_text'))
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.item.status === ItemStatus.ACTIVE ? $r('app.color.status_active_bg') : $r('app.color.status_done_bg'))
                  .borderRadius(4)
              }
              .position({ x: 16, y: 16 })
            }
            .width('100%')

            Column() {
              Text(this.item.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 12 })

              Row() {
                Text(getCategoryName(this.item.category))
                  .fontSize(12)
                  .fontColor($r('app.color.primary_color'))
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor($r('app.color.primary_light'))
                  .borderRadius(4)
                  .margin({ right: 8 })
                Text(formatTime(this.item.publishTime))
                  .fontSize(12)
                  .fontColor($r('app.color.text_hint'))
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))

            Column() {
              Text('物品描述')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 10 })
              Text(this.item.description)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(22)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .margin({ top: 10 })
            .alignItems(HorizontalAlign.Start)

            Column() {
              Row() {
                Text('📍 地点')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .width(80)
                Text(this.item.location)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })

              Divider()
                .color($r('app.color.divider_color'))

              Row() {
                Text('👤 发布者')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .width(80)
                Text(this.item.publisherName)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })

              Divider()
                .color($r('app.color.divider_color'))

              Row() {
                Text('📞 联系方式')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .width(80)
                Text(this.item.contact)
                  .fontSize(14)
                  .fontColor($r('app.color.primary_color'))
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .margin({ top: 10 })
            .alignItems(HorizontalAlign.Start)

            if (this.item.status === ItemStatus.ACTIVE) {
              Column() {
                Button(this.item.type === ItemType.LOST ? '我找到了' : '我要认领')
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor(this.item.type === ItemType.LOST ? $r('app.color.found_color') : $r('app.color.primary_color'))
                  .borderRadius(24)
                  .margin({ bottom: 12 })
                  .onClick(() => {
                    this.viewModel.markAsResolved(this.itemId);
                    const updated = this.viewModel.getItemById(this.itemId);
                    if (updated) {
                      this.item = updated;
                    }
                  })

                if (this.viewModel.isLoggedIn() && this.viewModel.currentUser!.id === this.item.publisherId) {
                  Button('下架信息')
                    .width('100%')
                    .height(48)
                    .fontSize(16)
                    .backgroundColor($r('app.color.bg_color'))
                    .fontColor($r('app.color.text_secondary'))
                    .borderRadius(24)
                    .onClick(() => {
                      this.viewModel.removeItem(this.itemId);
                      router.back();
                    })
                }
              }
              .width('100%')
              .padding(16)
              .margin({ top: 10 })
            } else {
              Column() {
                Text('✓ 此信息已完成')
                  .fontSize(15)
                  .fontColor($r('app.color.status_done_text'))
                  .textAlign(TextAlign.Center)
                  .width('100%')
              }
              .width('100%')
              .padding(24)
              .backgroundColor($r('app.color.status_done_bg'))
              .margin({ top: 10 })
              .borderRadius(12)
              .margin({ left: 16, right: 16 })
            }
          }
          .width('100%')
          .padding({ bottom: 40 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.bg_color'))
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Text('信息不存在或已被删除')
            .fontSize(16)
            .fontColor($r('app.color.text_hint'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.bg_color'))
      }
    }
    .title('详情')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}
