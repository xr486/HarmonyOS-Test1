import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { LostFoundItem, ItemType, ItemStatus, formatTime, getStatusText, getCategoryName } from '../common/bean/LostFoundItem';
import { UserStore } from '../common/store/UserStore';
import { ItemApi } from '../common/api/ItemApi';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface DetailPageParams {
  id: string;
}

@Entry
@Component
struct DetailPage {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State userStore: UserStore = UserStore.getInstance();
  @State itemId: string = '';
  @State item: LostFoundItem = new LostFoundItem();
  @State hasItem: boolean = false;
  @State isLoading: boolean = true;
  @State isMine: boolean = false;
  @State viewCount: number = 0;
  @State useApi: boolean = false;
  @State currentImageIndex: number = 0;
  @State showImagePreview: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as DetailPageParams;
    if (params && params.id) {
      this.itemId = params.id;
      this.loadDetail();
    }
  }

  async loadDetail(): Promise<void> {
    this.isLoading = true;
    try {
      if (this.useApi) {
        const result = await ItemApi.getItemDetail(this.itemId);
        if (result.code === 200 && result.data) {
          this.item = result.data as LostFoundItem;
          this.hasItem = true;
          this.isMine = (result.data as LostFoundItem).isMine || false;
          this.viewCount = (result.data as LostFoundItem).viewCount || 0;
        } else {
          this.hasItem = false;
          if (result.message && result.code !== 404) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } else {
        const found = this.viewModel.getItemById(this.itemId);
        if (found) {
          this.item = found;
          this.hasItem = true;
          this.isMine = this.viewModel.isLoggedIn() && this.viewModel.currentUser?.id === found.publisherId;
          this.viewCount = 0;
        } else {
          this.hasItem = false;
        }
      }
    } catch (e) {
      console.error('[DetailPage] loadDetail error:', JSON.stringify(e));
      this.hasItem = false;
    } finally {
      this.isLoading = false;
    }
  }

  async handleResolve(): Promise<void> {
    if (this.useApi) {
      if (!this.userStore.isLoggedIn) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/LoginPage' });
        return;
      }
      try {
        const result = await ItemApi.resolveItem(this.itemId);
        if (result.code === 200) {
          promptAction.showToast({ message: '操作成功', duration: 2000 });
          this.loadDetail();
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } catch (e) {
        console.error('[DetailPage] resolve error:', JSON.stringify(e));
        promptAction.showToast({ message: '操作失败，请重试', duration: 2000 });
      }
    } else {
      this.viewModel.markAsResolved(this.itemId);
      const updated = this.viewModel.getItemById(this.itemId);
      if (updated) {
        this.item = updated;
      }
      promptAction.showToast({ message: '操作成功', duration: 2000 });
    }
  }

  async handleRemove(): Promise<void> {
    if (this.useApi) {
      if (!this.userStore.isLoggedIn) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/LoginPage' });
        return;
      }
      try {
        const result = await ItemApi.deleteItem(this.itemId);
        if (result.code === 200) {
          promptAction.showToast({ message: '已下架', duration: 2000 });
          setTimeout(() => {
            router.back();
          }, 500);
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } catch (e) {
        console.error('[DetailPage] remove error:', JSON.stringify(e));
        promptAction.showToast({ message: '操作失败，请重试', duration: 2000 });
      }
    } else {
      this.viewModel.removeItem(this.itemId);
      promptAction.showToast({ message: '已下架', duration: 2000 });
      router.back();
    }
  }

  hasImages(): boolean {
    return this.item.images && this.item.images.length > 0;
  }

  @Builder
  LoadingView() {
    Column() {
      Text('加载中...')
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  ImageCarousel() {
    if (this.hasImages()) {
      Stack() {
        Swiper() {
          ForEach(this.item.images, (imageUrl: string, index: number) => {
            Image(imageUrl)
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                this.currentImageIndex = index;
                this.showImagePreview = true;
              })
              .alt('📷')
              .onError(() => {
                console.error('[DetailPage] image load error:', imageUrl);
              })
          }, (imageUrl: string, index: number) => index.toString())
        }
        .index(0)
        .autoPlay(false)
        .indicator(
          new SwiperDigitalIndicator()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .itemColor(Color.White)
            .selectedItemColor($r('app.color.primary_color'))
            .bottom(16)
        )
        .loop(false)
        .width('100%')
        .height(240)

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
    } else {
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
    }
  }

  @Builder
  ImagePreviewSheet() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(16)
          .fontColor(Color.White)
          .onClick(() => {
            this.showImagePreview = false;
          })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.End)

      if (this.hasImages()) {
        Swiper() {
          ForEach(this.item.images, (imageUrl: string, index: number) => {
            Image(imageUrl)
              .width('100%')
              .objectFit(ImageFit.Contain)
              .alt('📷')
              .onError(() => {
                console.error('[DetailPage] preview image load error:', imageUrl);
              })
          }, (imageUrl: string, index: number) => index.toString())
        }
        .index(this.currentImageIndex)
        .autoPlay(false)
        .indicator(
          new SwiperDigitalIndicator()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .itemColor(Color.White)
            .selectedItemColor($r('app.color.primary_color'))
            .bottom(20)
        )
        .loop(false)
        .layoutWeight(1)

        Text(`${this.currentImageIndex + 1} / ${this.item.images.length}`)
          .fontSize(14)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  build() {
    Navigation() {
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.hasItem) {
        Scroll() {
          Column() {
            this.ImageCarousel()

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

                Blank()

                if (this.viewCount > 0) {
                  Text(`👁 ${this.viewCount}`)
                    .fontSize(12)
                    .fontColor($r('app.color.text_hint'))
                }
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

            if (this.hasImages()) {
              Column() {
                Text('图片预览')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ bottom: 10 })
                
                Row({ space: 8 }) {
                  ForEach(this.item.images, (imageUrl: string, index: number) => {
                    Image(imageUrl)
                      .width(70)
                      .height(70)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                      .onClick(() => {
                        this.currentImageIndex = index;
                        this.showImagePreview = true;
                      })
                      .alt('📷')
                      .onError(() => {
                        console.error('[DetailPage] thumbnail load error:', imageUrl);
                      })
                  }, (imageUrl: string, index: number) => index.toString())
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .margin({ top: 10 })
              .alignItems(HorizontalAlign.Start)
            }

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
                    this.handleResolve();
                  })

                if (this.isMine) {
                  Row({ space: 12 }) {
                    Button('编辑')
                      .width('45%')
                      .height(48)
                      .fontSize(16)
                      .backgroundColor($r('app.color.primary_light'))
                      .fontColor($r('app.color.primary_color'))
                      .borderRadius(24)
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/EditPage',
                          params: { id: this.itemId }
                        });
                      })

                    Button('下架')
                      .width('45%')
                      .height(48)
                      .fontSize(16)
                      .backgroundColor($r('app.color.bg_color'))
                      .fontColor($r('app.color.text_secondary'))
                      .borderRadius(24)
                      .onClick(() => {
                        this.handleRemove();
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
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
        .bindSheet($$this.showImagePreview, this.ImagePreviewSheet(), {
          height: '100%',
          backgroundColor: Color.Black,
          onDisappear: () => {
            this.showImagePreview = false;
          }
        })
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