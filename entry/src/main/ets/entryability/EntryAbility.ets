import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TokenUtil } from '../common/utils/TokenUtil';
import { UserStore } from '../common/store/UserStore';
import router from '@ohos.router';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private launchWant: Want | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.launchWant = want;
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    try {
      TokenUtil.getInstance().init(this.context);
      UserStore.getInstance().init(this.context);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init stores. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.launchWant = want;
    this.handleLaunchParams(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err: Error) => {
      if (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  private handleLaunchParams(want: Want): void {
    if (!want || !want.parameters) {
      return;
    }

    const targetPage = want.parameters['targetPage'] as string;
    if (targetPage) {
      try {
        router.pushUrl({
          url: targetPage,
          params: want.parameters
        });
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', 'Failed to navigate from form: %{public}s', JSON.stringify(e));
      }
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}