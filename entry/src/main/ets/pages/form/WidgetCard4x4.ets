@Entry
@Component
struct WidgetCard4x4 {
  @LocalStorageLink('title') title: string = '失物招领';
  @LocalStorageLink('item1_title') item1Title: string = '加载中...';
  @LocalStorageLink('item1_type') item1Type: number = 0;
  @LocalStorageLink('item2_title') item2Title: string = '';
  @LocalStorageLink('item2_type') item2Type: number = 0;
  @LocalStorageLink('item3_title') item3Title: string = '';
  @LocalStorageLink('item3_type') item3Type: number = 0;
  @LocalStorageLink('item4_title') item4Title: string = '';
  @LocalStorageLink('item4_type') item4Type: number = 0;
  @LocalStorageLink('updateTime') updateTime: string = '--:--';

  @State currentTab: number = 0;

  build() {
    Column() {
      Row() {
        Column() {
          Text('失物招领')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          Text('校园互助平台')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Text('🔍')
            .fontSize(14)
            .margin({ right: 4 })
          Text('搜索')
            .fontSize(12)
            .fontColor('#5B8DEF')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#F0F5FF')
        .borderRadius(14)
        .postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            targetPage: 'pages/Index',
            action: 'search'
          }
        })
      }
      .width('100%')

      Row() {
        this.TabItem('全部', 0)
        this.TabItem('寻物', 1)
        this.TabItem('招领', 2)
        Blank()
        Text(`更新 ${this.updateTime}`)
          .fontSize(10)
          .fontColor('#BBBBBB')
      }
      .width('100%')
      .margin({ top: 12 })

      Column() {
        if (this.item1Title) {
          this.ItemRow(this.item1Title, this.item1Type, '学生卡丢失，有拾到者请联系', 1)
        }
        if (this.item2Title) {
          this.ItemRow(this.item2Title, this.item2Type, '图书馆三楼捡到书包一个', 2)
        }
        if (this.item3Title) {
          this.ItemRow(this.item3Title, this.item3Type, '食堂二楼丢失钥匙一串', 3)
        }
        if (this.item4Title) {
          this.ItemRow(this.item4Title, this.item4Type, '操场上捡到白色耳机一副', 4)
        }
        if (!this.item1Title && !this.item2Title && !this.item3Title && !this.item4Title) {
          Column() {
            Text('📭')
              .fontSize(32)
              .margin({ bottom: 8 })
            Text('暂无最新动态')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })

      Row() {
        Button('+ 立即发布')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#5B8DEF')
          .borderRadius(20)
          .height(36)
          .layoutWeight(1)
          .margin({ right: 8 })
          .postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/PublishPage'
            }
          })

        Button('查看全部')
          .fontSize(13)
          .fontColor('#5B8DEF')
          .backgroundColor('#F0F5FF')
          .borderRadius(20)
          .height(36)
          .layoutWeight(1)
          .postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/Index'
            }
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  TabItem(text: string, index: number) {
    Column() {
      Text(text)
        .fontSize(13)
        .fontColor(this.currentTab === index ? '#5B8DEF' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

      if (this.currentTab === index) {
        Circle()
          .width(4)
          .height(4)
          .fill('#5B8DEF')
          .margin({ top: 4 })
      } else {
        Circle()
          .width(4)
          .height(4)
          .fill(Color.Transparent)
          .margin({ top: 4 })
      }
    }
    .margin({ right: 16 })
    .postCardAction(this, {
      action: 'message',
      params: {
        action: 'switchTab',
        tabIndex: index
      }
    })
  }

  @Builder
  ItemRow(title: string, type: number, desc: string, index: number) {
    Row() {
      Column() {
        Text(type === 0 ? '寻' : '招')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width(32)
      .height(32)
      .backgroundColor(type === 0 ? '#FF6B35' : '#00B578')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 10 })

      Column() {
        Text(title)
          .fontSize(13)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(desc)
          .fontSize(11)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(14)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        targetPage: 'pages/DetailPage',
        itemIndex: index
      }
    })
  }
}