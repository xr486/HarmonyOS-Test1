import { AppViewModel, NewLostFoundItem } from '../common/viewmodel/AppViewModel';
import { ItemType, ItemCategory } from '../common/bean/LostFoundItem';
import { UserInfo } from '../common/bean/UserInfo';
import { UserStore } from '../common/store/UserStore';
import { ItemApi } from '../common/api/ItemApi';
import { UploadApi, UploadResult } from '../common/api/UploadApi';
import { PublishItemRequest } from '../common/model/ItemModel';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import picker from '@ohos.file.picker';

@Component
export struct PublishContent {
  @State viewModel: AppViewModel = AppViewModel.getInstance();
  @State userStore: UserStore = UserStore.getInstance();
  @State selectedType: ItemType = ItemType.LOST;
  @State selectedCategory: ItemCategory = ItemCategory.CARD;
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State contact: string = '';
  @State images: string[] = [];
  @State uploadingImages: boolean[] = [];
  @State showCategoryPicker: boolean = false;
  @State isPublishing: boolean = false;
  @State useApi: boolean = false;
  onPublished: () => void = () => {};

  private categories: string[] = ['证件卡片', '数码产品', '衣物服饰', '书籍文具', '其他物品'];
  private categoryValues: ItemCategory[] = [ItemCategory.CARD, ItemCategory.DIGITAL, ItemCategory.CLOTHING, ItemCategory.BOOK, ItemCategory.OTHER];
  private maxImages: number = 9;

  getCategoryName(): string {
    return this.categories[this.categoryValues.indexOf(this.selectedCategory)];
  }

  /**
   * 选择图片
   */
  async selectImages(): Promise<void> {
    if (this.images.length >= this.maxImages) {
      promptAction.showToast({ message: '最多添加9张图片', duration: 2000 });
      return;
    }

    try {
      const photoSelectOptions: picker.PhotoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = this.maxImages - this.images.length;
      
      const photoPicker: picker.PhotoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult: picker.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
      
      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        for (let i = 0; i < photoSelectResult.photoUris.length; i++) {
          const uri: string = photoSelectResult.photoUris[i];
          await this.uploadImage(uri);
        }
      }
    } catch (e) {
      console.error('[PublishPage] selectImages error:', JSON.stringify(e));
      // 如果选择器不可用，使用模拟模式
      if (this.images.length < this.maxImages) {
        this.images.push(`https://cdn.campus-lostandfound.com/items/mock_${Date.now()}.jpg`);
        promptAction.showToast({ message: '已添加模拟图片', duration: 1500 });
      }
    }
  }

  /**
   * 上传单张图片
   */
  async uploadImage(uri: string): Promise<void> {
    const tempIndex: number = this.images.length;
    this.images.push('');
    this.uploadingImages.push(true);

    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const result = await UploadApi.uploadImageSimple(uri, 'item');
        if (result.code === 200 && result.data) {
          this.images[tempIndex] = result.data.url;
          this.uploadingImages[tempIndex] = false;
        } else {
          // 上传失败，移除占位
          this.images.splice(tempIndex, 1);
          this.uploadingImages.splice(tempIndex, 1);
          promptAction.showToast({ message: result.message || '上传失败', duration: 2000 });
        }
      } else {
        // 不使用API时，使用模拟URL
        this.images[tempIndex] = `https://cdn.campus-lostandfound.com/items/mock_${Date.now()}.jpg`;
        this.uploadingImages[tempIndex] = false;
      }
    } catch (e) {
      console.error('[PublishPage] uploadImage error:', JSON.stringify(e));
      // 上传失败，移除占位
      this.images.splice(tempIndex, 1);
      this.uploadingImages.splice(tempIndex, 1);
      promptAction.showToast({ message: '上传失败，请重试', duration: 2000 });
    }
  }

  /**
   * 删除图片
   */
  removeImage(index: number): void {
    if (index >= 0 && index < this.images.length) {
      this.images.splice(index, 1);
      this.uploadingImages.splice(index, 1);
    }
  }

  async handlePublish(): Promise<void> {
    if (this.isPublishing) return;

    // 检查是否有正在上传的图片
    for (let i = 0; i < this.uploadingImages.length; i++) {
      if (this.uploadingImages[i]) {
        promptAction.showToast({ message: '请等待图片上传完成', duration: 2000 });
        return;
      }
    }

    if (this.useApi) {
      if (!this.userStore.isLoggedIn) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/LoginPage' });
        return;
      }
    } else {
      if (!this.viewModel.isLoggedIn()) {
        const user: UserInfo = new UserInfo();
        user.id = 'user_' + Date.now();
        user.name = '校园用户';
        this.viewModel.login(user);
        promptAction.showToast({ message: '已自动登录，可在"我的"页面管理信息', duration: 2000 });
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

    this.isPublishing = true;
    try {
      // 过滤掉空URL的图片
      const validImages: string[] = this.images.filter((url: string) => url && url.length > 0);

      if (this.useApi) {
        const request: PublishItemRequest = new PublishItemRequest();
        request.type = this.selectedType;
        request.category = this.selectedCategory;
        request.title = this.title.trim();
        request.description = this.description.trim();
        request.location = this.location.trim();
        request.contact = this.contact.trim();
        request.images = validImages;

        const result = await ItemApi.publishItem(request);
        if (result.code === 200) {
          promptAction.showToast({ message: '发布成功', duration: 2000 });
          this.resetForm();
          this.onPublished();
        } else {
          if (result.message) {
            promptAction.showToast({ message: result.message, duration: 2000 });
          }
        }
      } else {
        const newItem: NewLostFoundItem = new NewLostFoundItem();
        newItem.type = this.selectedType;
        newItem.category = this.selectedCategory;
        newItem.title = this.title.trim();
        newItem.description = this.description.trim();
        newItem.location = this.location.trim();
        newItem.contact = this.contact.trim();
        newItem.images = validImages;
        newItem.publisherId = this.viewModel.currentUser!.id;
        newItem.publisherName = this.viewModel.currentUser!.name;

        this.viewModel.addItem(newItem);
        this.resetForm();
        promptAction.showToast({ message: '发布成功', duration: 2000 });
        this.onPublished();
      }
    } catch (e) {
      console.error('[PublishPage] publish error:', JSON.stringify(e));
      promptAction.showToast({ message: '发布失败，请重试', duration: 2000 });
    } finally {
      this.isPublishing = false;
    }
  }

  resetForm(): void {
    this.title = '';
    this.description = '';
    this.location = '';
    this.contact = '';
    this.images = [];
    this.uploadingImages = [];
  }

  @Builder
  ImageCard(index: number) {
    Stack() {
      if (this.uploadingImages[index]) {
        // 上传中状态
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
        // 已完成上传
        Column() {
          Image(this.images[index])
            .width(70)
            .height(70)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .alt('📷')
            .onError(() => {
              console.error('[PublishPage] image load error:', this.images[index]);
            })
        }
        .width(70)
        .height(70)
        .backgroundColor($r('app.color.bg_color'))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
      
      // 删除按钮
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
          TextArea({ placeholder: '请详细描述物品特征、丢失/拾取时间等（10-500字）', text: this.description })
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
          TextInput({ placeholder: '请输入丢失/拾取地点（2-100字）', text: this.location })
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
          TextInput({ placeholder: '请输入手机号/微信/QQ等联系方式（2-50字）', text: this.contact })
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

        Button(this.isPublishing ? '发布中...' : '立即发布')
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor(!this.isPublishing ? $r('app.color.primary_color') : $r('app.color.divider_color'))
          .borderRadius(24)
          .enabled(!this.isPublishing)
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