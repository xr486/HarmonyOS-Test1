import { LostFoundItem } from '../bean/LostFoundItem';
import { BasicDataSource } from './BasicDataSource';

export class ItemDataSource extends BasicDataSource<LostFoundItem> {
  setData(data: LostFoundItem[]): void {
    this.dataArray = data;
    this.notifyDataReload();
  }

  addData(index: number, data: LostFoundItem): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: LostFoundItem): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }
}
