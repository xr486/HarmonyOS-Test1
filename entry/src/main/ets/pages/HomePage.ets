import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { ItemType, ItemCategory, LostFoundItem } from '../common/bean/LostFoundItem';
import { ItemDataSource } from '../common/component/ItemDataSource';
import { ItemCard } from '../common/component/ItemCard';
import { ServiceCard } from '../common/component/ServiceCard';
import router from '@ohos.router';

@Component
export struct HomeContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State searchText: string = '';
  @StorageLink('globalDataVersion')
  @Watch('onDataVersionChange')
  dataVersion: number = 0;
  private dataSource: ItemDataSource = new ItemDataSource();

  aboutToAppear() {
    this.updateList();
  }

  onDataVersionChange() {
    this.updateList();
  }

  updateList() {
    this.viewModel.searchKeyword = this.searchText;
    this.dataSource.setData(this.viewModel.getFilteredItems());
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
      this.viewModel.selectedType = type;
      this.updateList();
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
        this.viewModel.selectedCategory = category;
        this.updateList();
      })
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
            this.searchText = value;
          })
          .onSubmit(() => {
            this.updateList();
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

      List({ space: 0 }) {
        ListItem() {
          ServiceCard({
            items: this.viewModel.getLatestItems(3),
            onItemClick: (item: LostFoundItem) => {
              router.pushUrl({
                url: 'pages/DetailPage',
                params: { id: item.id }
              });
            }
          })
        }

        if (this.dataSource.totalCount() === 0) {
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
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
  }
}
