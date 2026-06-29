import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { ItemType, ItemCategory, LostFoundItem } from '../common/bean/LostFoundItem';
import { ItemDataSource } from '../common/component/ItemDataSource';
import { ItemCard } from '../common/component/ItemCard';
import { ServiceCard } from '../common/component/ServiceCard';
import { ItemApi } from '../common/api/ItemApi';
import { ItemQueryParams } from '../common/model/ItemModel';
import { PageResult } from '../common/model/ApiResult';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct HomeContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State searchText: string = '';
  @State itemList: LostFoundItem[] = [];
  @State latestItems: LostFoundItem[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State totalCount: number = 0;
  @State useApi: boolean = false;
  private dataSource: ItemDataSource = new ItemDataSource();
  private searchTimer: number = -1;

  aboutToAppear() {
    this.loadLatestItems();
    this.refreshList();
  }

  aboutToDisappear(): void {
    if (this.searchTimer !== -1) {
      clearTimeout(this.searchTimer);
      this.searchTimer = -1;
    }
  }

  loadLatestItems(): void {
    if (this.useApi) {
      ItemApi.getLatestItems(3).then(result => {
        if (result.code === 200 && result.data) {
          const list = result.data as Array<Object>;
          const items: LostFoundItem[] = [];
          for (let i = 0; i < list.length; i++) {
            const item = new LostFoundItem();
            const obj = list[i] as Record<string, Object>;
            item.id = obj.id as string;
            item.type = obj.type as number as ItemType;
            item.title = obj.title as string;
            item.publishTime = obj.publishTime as number;
            items.push(item);
          }
          this.latestItems = items;
        }
      }).catch(e => {
        console.error('[HomePage] loadLatestItems error:', JSON.stringify(e));
      });
    } else {
      this.latestItems = this.viewModel.getLatestItems(3);
    }
  }

  onSearchInput(value: string): void {
    this.searchText = value;
    if (this.searchTimer !== -1) {
      clearTimeout(this.searchTimer);
    }
    this.searchTimer = setTimeout(() => {
      this.refreshList();
    }, 500);
  }

  changeType(type: ItemType): void {
    if (this.viewModel.selectedType === type) return;
    this.viewModel.selectedType = type;
    this.refreshList();
  }

  changeCategory(category: ItemCategory): void {
    if (this.viewModel.selectedCategory === category) return;
    this.viewModel.selectedCategory = category;
    this.refreshList();
  }

  async refreshList(): Promise<void> {
    this.isRefreshing = true;
    this.currentPage = 1;
    this.hasMore = true;
    try {
      if (this.useApi) {
        const params: ItemQueryParams = new ItemQueryParams();
        params.type = this.viewModel.selectedType;
        if (this.viewModel.selectedCategory !== ItemCategory.ALL) {
          params.category = this.viewModel.selectedCategory;
        }
        params.status = 0;
        params.keyword = this.searchText.trim();
        params.pageNum = 1;
        params.pageSize = this.pageSize;

        const result = await ItemApi.getItemList(params);
        if (result.code === 200 && result.data) {
          const pageData = result.data as PageResult<LostFoundItem>;
          this.itemList = pageData.list || [];
          this.totalCount = pageData.total || 0;
          this.hasMore = this.itemList.length < this.totalCount;
        } else {
          this.itemList = [];
          this.hasMore = false;
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } else {
        this.viewModel.searchKeyword = this.searchText;
        this.itemList = this.viewModel.getFilteredItems();
        this.totalCount = this.itemList.length;
        this.hasMore = false;
      }
      this.dataSource.setData(this.itemList);
    } catch (e) {
      console.error('[HomePage] refreshList error:', JSON.stringify(e));
      promptAction.showToast({ message: '加载失败，请重试', duration: 2000 });
    } finally {
      this.isRefreshing = false;
    }
  }

  async loadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore || !this.useApi) return;

    this.isLoadingMore = true;
    this.currentPage++;
    try {
      const params: ItemQueryParams = new ItemQueryParams();
      params.type = this.viewModel.selectedType;
      if (this.viewModel.selectedCategory !== ItemCategory.ALL) {
        params.category = this.viewModel.selectedCategory;
      }
      params.status = 0;
      params.keyword = this.searchText.trim();
      params.pageNum = this.currentPage;
      params.pageSize = this.pageSize;

      const result = await ItemApi.getItemList(params);
      if (result.code === 200 && result.data) {
        const pageData = result.data as PageResult<LostFoundItem>;
        const newItems = pageData.list || [];
        this.itemList = this.itemList.concat(newItems);
        this.totalCount = pageData.total || 0;
        this.hasMore = this.itemList.length < this.totalCount && newItems.length > 0;
        this.dataSource.setData(this.itemList);
      }
    } catch (e) {
      console.error('[HomePage] loadMore error:', JSON.stringify(e));
      this.currentPage--;
    } finally {
      this.isLoadingMore = false;
    }
  }

  onReachBottom(): void {
    if (this.useApi && this.hasMore && !this.isLoadingMore) {
      this.loadMore();
    }
  }

  @Builder
  CategoryTab(title: string, type: ItemType) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(this.viewModel.selectedType === type ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.viewModel.selectedType === type ? $r('app.color.primary_color') : $r('app.color.text_secondary'))
      Divider()
        .strokeWidth(3)
        .color($r('app.color.primary_color'))
        .width(30)
        .opacity(this.viewModel.selectedType === type ? 1 : 0)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 8 })
    .onClick(() => {
      this.changeType(type);
    })
  }

  @Builder
  CategoryChip(title: string, category: ItemCategory) {
    Text(title)
      .fontSize(13)
      .fontColor(this.viewModel.selectedCategory === category ? Color.White : $r('app.color.text_secondary'))
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .backgroundColor(this.viewModel.selectedCategory === category ? $r('app.color.primary_color') : $r('app.color.white'))
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        this.changeCategory(category);
      })
  }

  @Builder
  LoadingFooter() {
    Row() {
      if (this.isLoadingMore) {
        Text('加载中...')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      } else if (!this.hasMore && this.itemList.length > 0) {
        Text('— 没有更多了 —')
          .fontSize(13)
          .fontColor($r('app.color.text_hint'))
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  SkeletonCard() {
    Column() {
      Row() {
        Column() {}.width(48).height(16).backgroundColor($r('app.color.divider_color')).borderRadius(4)
        Blank()
        Column() {}.width(50).height(16).backgroundColor($r('app.color.divider_color')).borderRadius(4)
      }
      .width('100%')

      Column() {}.width('100%').height(14).backgroundColor($r('app.color.divider_color')).borderRadius(4).margin({ top: 10 })
      Column() {}.width('70%').height(14).backgroundColor($r('app.color.divider_color')).borderRadius(4).margin({ top: 8 })

      Row() {
        Column() {}.width(60).height(12).backgroundColor($r('app.color.divider_color')).borderRadius(4)
        Blank()
        Column() {}.width(50).height(12).backgroundColor($r('app.color.divider_color')).borderRadius(4)
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.float.card_radius'))
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12, right: 8 })
        TextInput({ placeholder: '搜索物品名称、地点...', text: this.searchText })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding(0)
          .height(40)
          .onChange((value: string) => {
            this.onSearchInput(value);
          })
          .onSubmit(() => {
            this.refreshList();
          })
      }
      .width('100%')
      .backgroundColor($r('app.color.white'))
      .borderRadius(20)
      .margin({ left: 16, right: 16, top: 12, bottom: 8 })

      Row() {
        this.CategoryTab('寻物启事', ItemType.LOST)
        this.CategoryTab('失物招领', ItemType.FOUND)
      }
      .width('100%')
      .backgroundColor($r('app.color.white'))

      Scroll() {
        Row({ space: 8 }) {
          this.CategoryChip('全部', ItemCategory.ALL)
          this.CategoryChip('证件卡片', ItemCategory.CARD)
          this.CategoryChip('数码产品', ItemCategory.DIGITAL)
          this.CategoryChip('衣物服饰', ItemCategory.CLOTHING)
          this.CategoryChip('书籍文具', ItemCategory.BOOK)
          this.CategoryChip('其他', ItemCategory.OTHER)
        }
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.isRefreshing && this.itemList.length === 0) {
        Scroll() {
          Column() {
            this.SkeletonCard()
            this.SkeletonCard()
            this.SkeletonCard()
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        List({ space: 0 }) {
          ListItem() {
            ServiceCard({
              items: this.latestItems,
              onItemClick: (item: LostFoundItem) => {
                router.pushUrl({
                  url: 'pages/DetailPage',
                  params: { id: item.id }
                });
              }
            })
          }

          if (this.itemList.length === 0) {
            ListItem() {
              Column() {
                Text('📭')
                  .fontSize(48)
                  .margin({ bottom: 12 })
                Text('暂无相关信息')
                  .fontSize(14)
                  .fontColor($r('app.color.text_hint'))
              }
              .width('100%')
              .padding({ top: 60 })
            }
          } else {
            LazyForEach(this.dataSource, (item: LostFoundItem) => {
              ListItem() {
                ItemCard({
                  item: item,
                  onItemClick: (selectedItem: LostFoundItem) => {
                    router.pushUrl({
                      url: 'pages/DetailPage',
                      params: { id: selectedItem.id }
                    });
                  }
                })
              }
            }, (item: LostFoundItem) => item.id)
          }

          if (this.useApi && (this.isLoadingMore || this.hasMore || this.itemList.length > 0)) {
            ListItem() {
              this.LoadingFooter()
            }
          }
        }
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 20 })
        .onReachEnd(() => {
          this.onReachBottom();
        })
        .onScroll((_xOffset: number, yOffset: number) => {
          if (yOffset < -80 && !this.isRefreshing) {
            this.refreshList();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
  }
}
