@Entry
@Component
struct WidgetCard2x4 {
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

  build() {
    Column() {
      Row() {
        Text('🔔')
          .fontSize(18)
          .margin({ right: 8 })

        Column() {
          Text('失物招领')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          Text('校园最新动态')
            .fontSize(10)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Text('🔍')
            .fontSize(12)
            .margin({ right: 4 })
          Text('搜索')
            .fontSize(11)
            .fontColor('#5B8DEF')
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#F0F5FF')
        .borderRadius(12)
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

      Column() {
        if (this.item1Title) {
          this.ItemRow(this.item1Title, this.item1Type, 1)
        }
        if (this.item2Title) {
          this.ItemRow(this.item2Title, this.item2Type, 2)
        }
        if (this.item3Title) {
          this.ItemRow(this.item3Title, this.item3Type, 3)
        }
        if (this.item4Title) {
          this.ItemRow(this.item4Title, this.item4Type, 4)
        }
        if (!this.item1Title && !this.item2Title && !this.item3Title && !this.item4Title) {
          Column() {
            Text('暂无最新动态')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })

      Row() {
        Text(`更新于 ${this.updateTime}`)
          .fontSize(10)
          .fontColor('#BBBBBB')
        Blank()
        Text('查看更多 >')
          .fontSize(10)
          .fontColor('#5B8DEF')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        targetPage: 'pages/Index'
      }
    })
  }

  @Builder
  ItemRow(title: string, type: number, index: number) {
    Row() {
      Text(type === 0 ? '寻物' : '招领')
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor(type === 0 ? '#FF6B35' : '#00B578')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .margin({ right: 8 })

      Text(title)
        .fontSize(13)
        .fontColor('#333333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
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