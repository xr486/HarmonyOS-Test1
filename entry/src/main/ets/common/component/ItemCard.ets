import { LostFoundItem, ItemType, ItemStatus, formatTime, getStatusText } from '../bean/LostFoundItem';

@Component
export struct ItemCard {
  item: LostFoundItem = new LostFoundItem();
  onItemClick: (item: LostFoundItem) => void = (_item: LostFoundItem) => {};

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.item.type === ItemType.LOST ? '寻物' : '招领')
            .fontSize(12)
            .fontColor(this.item.type === ItemType.LOST ? $r('app.color.lost_color') : $r('app.color.found_color'))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(this.item.type === ItemType.LOST ? 'rgba(255,107,107,0.1)' : 'rgba(78,205,196,0.1)')
            .borderRadius(4)
            .margin({ right: 8 })
        }

        Text(this.item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        if (this.item.status !== ItemStatus.ACTIVE) {
          Text(getStatusText(this.item.status, this.item.type))
            .fontSize(11)
            .fontColor($r('app.color.status_done_text'))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor($r('app.color.status_done_bg'))
            .borderRadius(4)
        } else {
          Text('进行中')
            .fontSize(11)
            .fontColor($r('app.color.status_active_text'))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor($r('app.color.status_active_bg'))
            .borderRadius(4)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.item.description)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Row() {
        Row() {
          Text('📍')
            .fontSize(12)
          Text(this.item.location)
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .margin({ left: 2 })
        }

        Blank()

        Text(formatTime(this.item.publishTime))
          .fontSize(12)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.float.card_radius'))
    .margin({ bottom: 10 })
    .onClick(() => {
      this.onItemClick(this.item);
    })
  }
}
