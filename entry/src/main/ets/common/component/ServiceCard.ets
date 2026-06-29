import { LostFoundItem, ItemType, formatTime } from '../bean/LostFoundItem';

@Component
export struct ServiceCard {
  items: LostFoundItem[] = [];
  onItemClick: (item: LostFoundItem) => void = (_item: LostFoundItem) => {};

  build() {
    Column() {
      Row() {
        Text('🔔 最新动态')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text('查看更多 >')
          .fontSize(12)
          .fontColor($r('app.color.primary_color'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.items.length === 0) {
        Text('暂无最新动态')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .padding(20)
      } else {
        Column() {
          ForEach(this.items.slice(0, 3), (item: LostFoundItem) => {
            Row() {
              Text(item.type === ItemType.LOST ? '[寻物]' : '[招领]')
                .fontSize(13)
                .fontColor(item.type === ItemType.LOST ? $r('app.color.lost_color') : $r('app.color.found_color'))
                .margin({ right: 6 })

              Text(item.title)
                .fontSize(13)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(formatTime(item.publishTime))
                .fontSize(11)
                .fontColor($r('app.color.text_hint'))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .onClick(() => {
              this.onItemClick(item);
            })
          }, (item: LostFoundItem) => item.id)
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.float.card_radius'))
    .margin({ bottom: 12 })
  }
}
