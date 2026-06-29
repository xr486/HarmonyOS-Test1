import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { ItemType, ItemCategory, LostFoundItem } from '../common/bean/LostFoundItem';
import { UserStore } from '../common/store/UserStore';
import { ItemApi } from '../common/api/ItemApi';
import { UploadApi } from '../common/api/UploadApi';
import { UpdateItemRequest } from '../common/model/ItemModel';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

interface EditPageParams {
  id: string;
}

@Entry
@Component
struct EditPage {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State userStore: UserStore = UserStore.getInstance();
  @State itemId: string = '';
  @State selectedType: ItemType = ItemType.LOST;
  @State selectedCategory: ItemCategory = ItemCategory.CARD;
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State contact: string = '';
  @State images: string[] = [];
  @State uploadingImages: boolean[] = [];
  @State showCategoryPicker: boolean = false;
  @State isUpdating: boolean = false;
  @State isLoading: boolean = true;
  @State useApi: boolean = false;

  private categories: string[] = ['证件卡片', '数码产品', '衣物服饰', '书籍文具', '其他物品'];
  private categoryValues: ItemCategory[] = [ItemCategory.CARD, ItemCategory.DIGITAL, ItemCategory.CLOTHING, ItemCategory.BOOK, ItemCategory.OTHER];
  private maxImages: number = 9;

  aboutToAppear() {
    const params = router.getParams() as EditPageParams;
    if (params && params.id) {
      this.itemId = params.id;
      this.loadItemData();
    }
  }

  async loadItemData(): Promise<void> {
    this.isLoading = true;
    try {
      if (this.useApi) {
        const result = await ItemApi.getItemDetail(this.itemId);
        if (result.code === 200 && result.data) {
          const item = result.data as LostFoundItem;
          this.selectedType = item.type;
          this.selectedCategory = item.category;
          this.title = item.title;
          this.description = item.description;
          this.location = item.location;
          this.contact = item.contact;
          this.images = item.images || [];
          this.uploadingImages = this.images.map(() => false);
        } else {
          promptAction.showToast({ message: result.message || '加载失败', duration: 2000 });
          router.back();
        }
      } else {
        const item = this.viewModel.getItemById(this.itemId);
        if (item) {
          this.selectedType = item.type;
          this.selectedCategory = item.category;
          this.title = item.title;
          this.description = item.description;
          this.location = item.location;
          this.contact = item.contact;
          this.images = item.images || [];
          this.uploadingImages = this.images.map(() => false);
        } else {
          promptAction.showToast({ message: '物品不存在', duration: 2000 });
          router.back();
        }
      }
    } catch (e) {
      console.error('[EditPage] loadItemData error:', JSON.stringify(e));
      promptAction.showToast({ message: '加载失败', duration: 2000 });
      router.back();
    } finally {
      this.isLoading = false;
    }
  }

  getCategoryName(): string {
    return this.categories[this.categoryValues.indexOf(this.selectedCategory)];
  }

  async selectImages(): Promise<void> {
    if (this.images.length >= this.maxImages) {
      promptAction.showToast({ message: '最多添加9张图片', duration: 2000 });
      return;
    }

    try {
      // 尝试使用图片选择器
      const result = await UploadApi.uploadImageSimple('', 'item');
      if (result.code === 200 && result.data) {
        this.images.push(result.data.url);
        this.uploadingImages.push(false);
      }
    } catch (e) {
      console.error('[EditPage] selectImages error:', JSON.stringify(e));
      if (this.images.length < this.maxImages) {
        this.images.push(`https://cdn.campus-lostandfound.com/items/mock_${Date.now()}.jpg`);
        this.uploadingImages.push(false);
      }
    }
  }

  removeImage(index: number): void {
    if (index >= 0 && index < this.images.length) {
      this.images.splice(index, 1);
      this.uploadingImages.splice(index, 1);
    }
  }

  async handleUpdate(): Promise<void> {
    if (this.isUpdating) return;

    for (let i = 0; i < this.uploadingImages.length; i++) {
      if (this.uploadingImages[i]) {
        promptAction.showToast({ message: '请等待图片上传完成', duration: 2000 });
        return;
      }
    }

    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入物品名称', duration: 2000 });
      return;
    }
    if (this.title.trim().length < 2 || this.title.trim().length > 50) {
      promptAction.showToast({ message: '物品名称2-50字', duration: 2000 });
      return;
    }
    if (!this.description.trim()) {
      promptAction.showToast({ message: '请输入物品描述', duration: 2000 });
      return;
    }
    if (this.description.trim().length < 10 || this.description.trim().length > 500) {
      promptAction.showToast({ message: '物品描述10-500字', duration: 2000 });
      return;
    }
    if (!this.location.trim()) {
      promptAction.showToast({ message: '请输入地点', duration: 2000 });
      return;
    }
    if (this.location.trim().length < 2 || this.location.trim().length > 100) {
      promptAction.showToast({ message: '地点2-100字', duration: 2000 });
      return;
    }
    if (!this.contact.trim()) {
      promptAction.showToast({ message: '请输入联系方式', duration: 2000 });
      return;
    }
    if (this.contact.trim().length < 2 || this.contact.trim().length > 50) {
      promptAction.showToast({ message: '联系方式2-50字', duration: 2000 });
      return;
    }

    this.isUpdating = true;
    try {
      const validImages: string[] = this.images.filter((url: string) => url && url.length > 0);

      if (this.useApi) {
        const request: UpdateItemRequest = {
          type: this.selectedType,
          category: this.selectedCategory,
          title: this.title.trim(),
          description: this.description.trim(),
          location: this.location.trim(),
          contact: this.contact.trim(),
          images: validImages
        };

        const result = await ItemApi.updateItem(this.itemId, request);
        if (result.code === 200) {
          promptAction.showToast({ message: '更新成功', duration: 2000 });
          router.back();
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } else {
        const item = this.viewModel.getItemById(this.itemId);
        if (item) {
          item.type = this.selectedType;
          item.category = this.selectedCategory;
          item.title = this.title.trim();
          item.description = this.description.trim();
          item.location = this.location.trim();
          item.contact = this.contact.trim();
          item.images = validImages;
          item.updateTime = Date.now();
        }
        promptAction.showToast({ message: '更新成功', duration: 2000 });
        router.back();
      }
    } catch (e) {
      console.error('[EditPage] update error:', JSON.stringify(e));
      promptAction.showToast({ message: '更新失败，请重试', duration: 2000 });
    } finally {
      this.isUpdating = false;
    }
  }

  @Builder
  ImageCard(index: number) {
    Stack() {
      if (this.uploadingImages[index]) {
        Column() {
          Progress({ value: 0, total: 100, type: ProgressType.Circular })
            .width(24)
            .height(24)
            .color($r('app.color.primary_color'))
        }
        .width(70)
        .height(70)
        .backgroundColor($r('app.color.bg_color'))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Image(this.images[index])
            .width(70)
            .height(70)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .alt('📷')
        }
        .width(70)
        .height(70)
        .backgroundColor($r('app.color.bg_color'))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }

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
          this.removeImage(index);
        })
    }
  }

  @Builder
  LoadingView() {
    Column() {
      Progress({ value: 0, total: 100, type: ProgressType.Circular })
        .width(48)
        .height(48)
        .color($r('app.color.primary_color'))
      Text('加载中...')
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_color'))
  }

  build() {
    Navigation() {
      if (this.isLoading) {
        this.LoadingView()
      } else {
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
              TextInput({ placeholder: '请输入物品名称（2-50字）', text: this.title })
                .width('100%')
                .backgroundColor($r('app.color.bg_color'))
                .borderRadius(8)
                .padding(12)
                .maxLength(50)
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
              TextArea({ placeholder: '请详细描述物品特征（10-500字）', text: this.description })
                .width('100%')
                .backgroundColor($r('app.color.bg_color'))
                .borderRadius(8)
                .padding(12)
                .height(100)
                .maxLength(500)
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
              TextInput({ placeholder: '请输入地点（2-100字）', text: this.location })
                .width('100%')
                .backgroundColor($r('app.color.bg_color'))
                .borderRadius(8)
                .padding(12)
                .maxLength(100)
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
              TextInput({ placeholder: '请输入联系方式（2-50字）', text: this.contact })
                .width('100%')
                .backgroundColor($r('app.color.bg_color'))
                .borderRadius(8)
                .padding(12)
                .maxLength(50)
                .onChange((value: string) => {
                  this.contact = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })
            .alignItems(HorizontalAlign.Start)

            Column() {
              Row() {
                Text('添加图片')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                Text(`（最多${this.maxImages}张）`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_hint'))
              }
              .margin({ bottom: 8 })

              Row({ space: 8 }) {
                ForEach(this.images, (_img: string, index: number) => {
                  this.ImageCard(index)
                }, (_img: string, index: number) => index.toString())

                if (this.images.length < this.maxImages) {
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
                    this.selectImages();
                  })
                }
              }
            }
            .width('100%')
            .margin({ bottom: 24 })
            .alignItems(HorizontalAlign.Start)

            Button(this.isUpdating ? '保存中...' : '保存修改')
              .width('100%')
              .height(48)
              .fontSize(16)
              .backgroundColor(!this.isUpdating ? $r('app.color.primary_color') : $r('app.color.divider_color'))
              .borderRadius(24)
              .enabled(!this.isUpdating)
              .onClick(() => {
                this.handleUpdate();
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
    }
    .title('编辑')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
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