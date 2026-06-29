import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { LostFoundItem, ItemStatus, formatTime, getStatusText } from '../common/bean/LostFoundItem';
import { UserStore } from '../common/store/UserStore';
import { ItemApi } from '../common/api/ItemApi';
import { PageResult } from '../common/model/ApiResult';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct ProfileContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State userStore: UserStore = UserStore.getInstance();
  @State myItems: LostFoundItem[] = [];
  @State activeCount: number = 0;
  @State doneCount: number = 0;
  @State totalCount: number = 0;
  @State isLoading: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State useApi: boolean = false;
  onGoPublish: () => void = () => {};

  aboutToAppear() {
    this.loadMyItems();
  }

  onPageShow() {
    if (this.userStore.isLoggedIn) {
      this.loadMyItems();
    }
  }

  async loadMyItems(isRefresh: boolean = true): Promise<void> {
    if (!this.userStore.isLoggedIn && !this.viewModel.isLoggedIn()) {
      this.myItems = [];
      this.activeCount = 0;
      this.doneCount = 0;
      this.totalCount = 0;
      return;
    }

    if (isRefresh) {
      this.isLoading = true;
      this.currentPage = 1;
      this.hasMore = true;
    } else {
      if (this.isLoadingMore || !this.hasMore) return;
      this.isLoadingMore = true;
      this.currentPage++;
    }

    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const result = await ItemApi.getMyItems(-1, this.currentPage, this.pageSize);
        if (result.code === 200 && result.data) {
          const pageData = result.data as PageResult<LostFoundItem>;
          const list = pageData.list || [];
          if (isRefresh) {
            this.myItems = list;
          } else {
            this.myItems = this.myItems.concat(list);
          }
          this.totalCount = pageData.total || 0;
          this.hasMore = this.myItems.length < this.totalCount && list.length > 0;
          this.calculateStats();
        }
      } else {
        const result = await this.viewModel.getMyPublishedItems();
        const items = result.list;
        if (isRefresh) {
          this.myItems = items;
        }
        this.totalCount = result.total;
        this.hasMore = false;
        this.calculateStats();
      }
    } catch (e) {
      console.error('[ProfilePage] loadMyItems error:', JSON.stringify(e));
      if (!isRefresh) {
        this.currentPage--;
      }
    } finally {
      if (isRefresh) {
        this.isLoading = false;
      } else {
        this.isLoadingMore = false;
      }
    }
  }

  calculateStats(): void {
    let active = 0;
    let done = 0;
    for (let i = 0; i < this.myItems.length; i++) {
      if (this.myItems[i].status === ItemStatus.ACTIVE) {
        active++;
      } else {
        done++;
      }
    }
    this.activeCount = active;
    this.doneCount = done;
  }

  handleLogin() {
    router.pushUrl({
      url: 'pages/LoginPage'
    });
  }

  handleLogout() {
    this.userStore.logout();
    this.viewModel.logout();
    this.myItems = [];
    this.activeCount = 0;
    this.doneCount = 0;
    this.totalCount = 0;
    promptAction.showToast({ message: '已退出登录', duration: 2000 });
  }

  goEditProfile() {
    router.pushUrl({
      url: 'pages/EditProfilePage'
    });
  }

  async handleMarkResolved(item: LostFoundItem): Promise<void> {
    if (this.useApi) {
      if (!this.userStore.isLoggedIn) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/LoginPage' });
        return;
      }
      try {
        const result = await ItemApi.resolveItem(item.id);
        if (result.code === 200) {
          promptAction.showToast({ message: '操作成功', duration: 2000 });
          this.loadMyItems(true);
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } catch (e) {
        console.error('[ProfilePage] markResolved error:', JSON.stringify(e));
        promptAction.showToast({ message: '操作失败，请重试', duration: 2000 });
      }
    } else {
      this.viewModel.markAsResolved(item.id);
      this.loadMyItems(true);
    }
  }

  async handleRemoveItem(item: LostFoundItem): Promise<void> {
    if (this.useApi) {
      if (!this.userStore.isLoggedIn) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/LoginPage' });
        return;
      }
      try {
        const result = await ItemApi.deleteItem(item.id);
        if (result.code === 200) {
          promptAction.showToast({ message: '已下架', duration: 2000 });
          this.loadMyItems(true);
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } catch (e) {
        console.error('[ProfilePage] removeItem error:', JSON.stringify(e));
        promptAction.showToast({ message: '操作失败，请重试', duration: 2000 });
      }
    } else {
      this.viewModel.removeItem(item.id);
      this.loadMyItems(true);
    }
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
                this.handleMarkResolved(item);
              })
            Text('下架')
              .fontSize(12)
              .fontColor($r('app.color.lost_color'))
              .margin({ left: 12 })
              .onClick(() => {
                this.handleRemoveItem(item);
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

  @Builder
  UserInfoSection() {
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
          if (this.userStore.isLoggedIn && this.userStore.userInfo) {
            Text(this.userStore.userInfo.name)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            if (this.userStore.userInfo.studentId) {
              Text('学号：' + this.userStore.userInfo.studentId)
                .fontSize(13)
                .fontColor($r('app.color.text_hint'))
                .margin({ top: 4 })
            }
          } else if (this.viewModel.isLoggedIn() && this.viewModel.currentUser) {
            Text(this.viewModel.currentUser.name)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
          } else {
            Text('点击登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(' >')
          .fontSize(16)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
      .padding(16)
      .onClick(() => {
        if (this.userStore.isLoggedIn || this.viewModel.isLoggedIn()) {
          this.goEditProfile();
        } else {
          this.handleLogin();
        }
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
  }

  @Builder
  LoadingFooter() {
    Row() {
      if (this.isLoadingMore) {
        Text('加载中...')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      } else if (!this.hasMore && this.myItems.length > 0) {
        Text('— 没有更多了 —')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      this.UserInfoSection()

      Row() {
        Column() {
          Text(this.activeCount.toString())
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
          Text(this.doneCount.toString())
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
          Text(this.totalCount.toString())
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

      Column() {
        Row() {
          Text('我的发布')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .padding(16)

        if (!this.userStore.isLoggedIn && !this.viewModel.isLoggedIn()) {
          Column() {
            Text('🔒')
              .fontSize(48)
              .margin({ bottom: 12 })
            Text('请先登录查看发布记录')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))
            Button('去登录')
              .fontSize(14)
              .height(36)
              .margin({ top: 16 })
              .backgroundColor($r('app.color.primary_color'))
              .onClick(() => {
                this.handleLogin();
              })
          }
          .width('100%')
          .padding({ top: 60 })
        } else if (this.myItems.length === 0 && !this.isLoading) {
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
          List() {
            ForEach(this.myItems, (item: LostFoundItem) => {
              ListItem() {
                this.MyItemCard(item)
              }
            }, (item: LostFoundItem) => item.id)

            if (this.useApi && (this.isLoadingMore || this.hasMore || this.myItems.length > 0)) {
              ListItem() {
                this.LoadingFooter()
              }
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .onReachEnd(() => {
            if (this.useApi && this.hasMore && !this.isLoadingMore) {
              this.loadMyItems(false);
            }
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.bg_color'))
      .margin({ top: 10 })

      if (this.userStore.isLoggedIn || this.viewModel.isLoggedIn()) {
        Column() {
          Button('退出登录')
            .width('80%')
            .height(44)
            .fontSize(15)
            .backgroundColor($r('app.color.white'))
            .fontColor($r('app.color.lost_color'))
            .borderRadius(22)
            .onClick(() => {
              this.handleLogout();
            })
        }
        .width('100%')
        .padding({ top: 10, bottom: 20 })
        .backgroundColor($r('app.color.bg_color'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
  }
}
