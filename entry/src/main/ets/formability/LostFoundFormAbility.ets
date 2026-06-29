import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formInfo from '@ohos.app.form.formInfo';
import formProvider from '@ohos.app.form.formProvider';
import { AppViewModel } from '../common/viewmodel/AppViewModel';
import { LostFoundItem } from '../common/bean/LostFoundItem';

export default class LostFoundFormAbility extends FormExtensionAbility {
  private viewModel: AppViewModel = AppViewModel.getInstance();

  onAddForm(want: Want): formBindingData.FormBindingData {
    console.log('[LostFoundFormAbility] onAddForm, want:', JSON.stringify(want));
    const formData = this.getFormData();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    console.log('[LostFoundFormAbility] onCastToNormalForm, formId:', formId);
  }

  onUpdateForm(formId: string): void {
    console.log('[LostFoundFormAbility] onUpdateForm, formId:', formId);
    this.updateFormData(formId);
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
    console.log('[LostFoundFormAbility] onChangeFormVisibility, newStatus:', JSON.stringify(newStatus));
    for (const formId in newStatus) {
      if (newStatus[formId] === formInfo.FormVisibleState.VISIBLE) {
        this.updateFormData(formId);
      }
    }
  }

  onFormEvent(formId: string, message: string): void {
    console.log('[LostFoundFormAbility] onFormEvent, formId:', formId, 'message:', message);
  }

  onRemoveForm(formId: string): void {
    console.log('[LostFoundFormAbility] onRemoveForm, formId:', formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    console.log('[LostFoundFormAbility] onAcquireFormState');
    return formInfo.FormState.READY;
  }

  private async getFormData(): Promise<Record<string, Object>> {
    try {
      const items = await this.viewModel.getLatestItems(4);
      const itemList: Record<string, Object>[] = items.map((item: LostFoundItem) => ({
        id: item.id,
        title: item.title,
        type: item.type,
        location: item.location,
        time: this.formatTime(item.publishTime)
      }));

      return {
        title: '失物招领',
        subtitle: '最新动态',
        itemList: itemList as Object,
        item1_title: items.length > 0 ? items[0].title : '暂无数据',
        item1_type: items.length > 0 ? items[0].type : 0,
        item2_title: items.length > 1 ? items[1].title : '',
        item2_type: items.length > 1 ? items[1].type : 0,
        item3_title: items.length > 2 ? items[2].title : '',
        item3_type: items.length > 2 ? items[2].type : 0,
        item4_title: items.length > 3 ? items[3].title : '',
        item4_type: items.length > 3 ? items[3].type : 0,
        updateTime: this.formatTime(Date.now())
      };
    } catch (e) {
      console.error('[LostFoundFormAbility] getFormData error:', JSON.stringify(e));
      return {
        title: '失物招领',
        subtitle: '最新动态',
        itemList: [] as Object,
        item1_title: '加载中...',
        item1_type: 0,
        updateTime: '--:--'
      };
    }
  }

  private async updateFormData(formId: string): Promise<void> {
    try {
      const formData = await this.getFormData();
      const formBinding = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, formBinding);
    } catch (e) {
      console.error('[LostFoundFormAbility] updateFormData error:', JSON.stringify(e));
    }
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}