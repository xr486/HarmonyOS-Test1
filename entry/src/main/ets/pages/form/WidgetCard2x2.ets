@Entry
@Component
struct WidgetCard2x2 {
  @LocalStorageLink('title') title: string = '失物招领';
  @LocalStorageLink('item1_title') item1Title: string = '加载中...';
  @LocalStorageLink('item1_type') item1Type: number = 0;
  @LocalStorageLink('item2_title') item2Title: string = '';
  @LocalStorageLink('item2_type') item2Type: number = 0;
  @LocalStorageLink('updateTime') updateTime: string = '--:--';

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          Text('校园失物招领')
            .fontSize(10)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('🔍')
          .fontSize(16)
      }
      .width('100%')

      Column() {
        if (this.item1Title) {
          Row() {
            Text(this.item1Type === 0 ? '寻' : '招')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor(this.item1Type === 0 ? '#FF6B35' : '#00B578')
              .borderRadius(3)
              .width(18)
              .height(18)
              .textAlign(TextAlign.Center)
              .margin({ right: 6 })

            Text(this.item1Title)
              .fontSize(12)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 10 })
        }

        if (this.item2Title) {
          Row() {
            Text(this.item2Type === 0 ? '寻' : '招')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor(this.item2Type === 0 ? '#FF6B35' : '#00B578')
              .borderRadius(3)
              .width(18)
              .height(18)
              .textAlign(TextAlign.Center)
              .margin({ right: 6 })

            Text(this.item2Title)
              .fontSize(12)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 8 })
        }

        if (!this.item1Title && !this.item2Title) {
          Text('暂无动态')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 14 })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 8 })

      Row() {
        Text(`更新于 ${this.updateTime}`)
          .fontSize(9)
          .fontColor('#BBBBBB')
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
}