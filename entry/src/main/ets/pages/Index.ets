import { HomeContent } from './HomePage';
import { PublishContent } from './PublishPage';
import { ProfileContent } from './ProfilePage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State breakPoint: string = 'sm';
  private controller: TabsController = new TabsController();

  @Builder
  TabTitle(title: string, icon: ResourceStr) {
    Column() {
      Text(icon)
        .fontSize(22)
      Text(title)
        .fontSize(11)
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          HomeContent()
        }
        .tabBar(this.TabTitle('首页', '🏠'))

        TabContent() {
          PublishContent({ onPublished: () => {
            this.controller.changeIndex(0);
          }})
        }
        .tabBar(this.TabTitle('发布', '➕'))

        TabContent() {
          ProfileContent({ onGoPublish: () => {
            this.controller.changeIndex(1);
          }})
        }
        .tabBar(this.TabTitle('我的', '👤'))
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .vertical(false)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .barMode(BarMode.Fixed)
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      const width = Number(newValue.width);
      if (width < 600) {
        this.breakPoint = 'sm';
      } else if (width < 840) {
        this.breakPoint = 'md';
      } else {
        this.breakPoint = 'lg';
      }
    })
  }
}
