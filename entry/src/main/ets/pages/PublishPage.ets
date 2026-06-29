import { AppViewModel, NewLostFoundItem } from '../common/viewmodel/AppViewModel';
import { ItemType, ItemCategory } from '../common/bean/LostFoundItem';
import { UserInfo } from '../common/bean/UserInfo';
import promptAction from '@ohos.promptAction';

@Component
export struct PublishContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State selectedType: ItemType = ItemType.LOST;
  @State selectedCategory: ItemCategory = ItemCategory.CARD;
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State contact: string = '';
  @State images: string[] = [];
  @State showCategoryPicker: boolean = false;
  onPublished: () => void = () => {};

  private categories: string[] = ['证件卡片', '数码产品', '衣物服饰', '书籍文具', '其他物品'];
  private categoryValues: ItemCategory[] = [ItemCategory.CARD, ItemCategory.DIGITAL, ItemCategory.CLOTHING, ItemCategory.BOOK, ItemCategory.OTHER];

  getCategoryName(): string {
    return this.categories[this.categoryValues.indexOf(this.selectedCategory)];
  }

  handlePublish() {
    if (!this.viewModel.isLoggedIn()) {
      const user: UserInfo = new UserInfo();
      user.id = 'user_' + Date.now();
      user.name = '校园用户';
      this.viewModel.login(user);
    }

    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入物品名称' });
      return;
    }
    if (!this.description.trim()) {
      promptAction.showToast({ message: '请输入物品描述' });
      return;
    }
    if (!this.location.trim()) {
      promptAction.showToast({ message: '请输入地点' });
      return;
    }
    if (!this.contact.trim()) {
      promptAction.showToast({ message: '请输入联系方式' });
      return;
    }

    const newItem: NewLostFoundItem = new NewLostFoundItem();
    newItem.type = this.selectedType;
    newItem.category = this.selectedCategory;
    newItem.title = this.title.trim();
    newItem.description = this.description.trim();
    newItem.location = this.location.trim();
    newItem.contact = this.contact.trim();
    newItem.images = this.images;
    newItem.publisherId = this.viewModel.currentUser!.id;
    newItem.publisherName = this.viewModel.currentUser!.name;

    this.viewModel.addItem(newItem);

    this.title = '';
    this.description = '';
    this.location = '';
    this.contact = '';
    this.images = [];

    promptAction.showToast({ message: '发布成功' });
    this.onPublished();
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('信息类型')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)
          Row({ space: 12 }) {
            Button('寻物启事')
              .type(ButtonType.Normal)
              .backgroundColor(this.selectedType === ItemType.LOST ? $r('app.color.lost_color') : $r('app.color.bg_color'))
              .fontColor(this.selectedType === ItemType.LOST ? Color.White : $r('app.color.text_secondary'))
              .fontSize(14)
              .height(36)
              .onClick(() => {
                this.selectedType = ItemType.LOST;
              })
            Button('失物招领')
              .type(ButtonType.Normal)
              .backgroundColor(this.selectedType === ItemType.FOUND ? $r('app.color.found_color') : $r('app.color.bg_color'))
              .fontColor(this.selectedType === ItemType.FOUND ? Color.White : $r('app.color.text_secondary'))
              .fontSize(14)
              .height(36)
              .onClick(() => {
                this.selectedType = ItemType.FOUND;
              })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })

        Row() {
          Text('物品类型')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)
          Text(this.getCategoryName() + ' >')
            .fontSize(14)
            .fontColor($r('app.color.primary_color'))
            .onClick(() => {
              this.showCategoryPicker = true;
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.bg_color'))
        .borderRadius(8)
        .margin({ bottom: 16 })

        Column() {
          Text('物品名称')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          TextInput({ placeholder: '请输入物品名称', text: this.title })
            .width('100%')
            .backgroundColor($r('app.color.bg_color'))
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => {
              this.title = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('物品描述')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          TextArea({ placeholder: '请详细描述物品特征、丢失/拾取时间等', text: this.description })
            .width('100%')
            .backgroundColor($r('app.color.bg_color'))
            .borderRadius(8)
            .padding(12)
            .height(100)
            .onChange((value: string) => {
              this.description = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('地点')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          TextInput({ placeholder: '请输入丢失/拾取地点', text: this.location })
            .width('100%')
            .backgroundColor($r('app.color.bg_color'))
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => {
              this.location = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('联系方式')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          TextInput({ placeholder: '请输入手机号/微信/QQ等联系方式', text: this.contact })
            .width('100%')
            .backgroundColor($r('app.color.bg_color'))
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => {
              this.contact = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('添加图片')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          Row({ space: 8 }) {
            ForEach(this.images, (_img: string, index: number) => {
              Stack() {
                Column() {
                  Text('📷')
                    .fontSize(28)
                }
                .width(70)
                .height(70)
                .backgroundColor($r('app.color.bg_color'))
                .borderRadius(8)
                .justifyContent(FlexAlign.Center)
                Text('×')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor(Color.Black)
                  .borderRadius(10)
                  .width(20)
                  .height(20)
                  .textAlign(TextAlign.Center)
                  .position({ x: 52, y: 0 })
                  .onClick(() => {
                    this.images.splice(index, 1);
                  })
              }
            }, (_img: string, index: number) => index.toString())
            if (this.images.length < 3) {
              Column() {
                Text('+')
                  .fontSize(28)
                  .fontColor($r('app.color.text_hint'))
              }
              .width(70)
              .height(70)
              .backgroundColor($r('app.color.bg_color'))
              .borderRadius(8)
              .border({ width: 1, color: $r('app.color.divider_color'), style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.images.push('');
              })
            }
          }
        }
        .width('100%')
        .margin({ bottom: 24 })
        .alignItems(HorizontalAlign.Start)

        Button('立即发布')
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor($r('app.color.primary_color'))
          .borderRadius(24)
          .onClick(() => {
            this.handlePublish();
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.white'))
    .scrollBar(BarState.Off)
    .bindSheet($$this.showCategoryPicker, this.CategoryPickerSheet(), {
      height: 300,
      onDisappear: () => {
        this.showCategoryPicker = false;
      }
    })
  }

  @Builder
  CategoryPickerSheet() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor($r('app.color.text_hint'))
          .onClick(() => {
            this.showCategoryPicker = false;
          })
        Blank()
        Text('选择物品类型')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('确定')
          .fontSize(16)
          .fontColor($r('app.color.primary_color'))
          .onClick(() => {
            this.showCategoryPicker = false;
          })
      }
      .width('100%')
      .padding(16)

      List() {
        ForEach(this.categories, (cat: string, index: number) => {
          ListItem() {
            Row() {
              Text(cat)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
              if (this.selectedCategory === this.categoryValues[index]) {
                Text('✓')
                  .fontSize(18)
                  .fontColor($r('app.color.primary_color'))
              }
            }
            .width('100%')
            .padding(16)
            .onClick(() => {
              this.selectedCategory = this.categoryValues[index];
            })
          }
        })
      }
      .width('100%')
      .divider({ strokeWidth: 1, color: $r('app.color.divider_color') })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
  }
}
