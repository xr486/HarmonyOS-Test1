export enum ItemType {
  LOST = 0,
  FOUND = 1
}

export enum ItemCategory {
  CARD = 1,
  DIGITAL = 2,
  CLOTHING = 3,
  BOOK = 4,
  OTHER = 5,
  ALL = 0
}

export enum ItemStatus {
  ACTIVE = 0,
  CLAIMED = 1,
  RETURNED = 2
}

export class LostFoundItem {
  id: string = '';
  type: ItemType = ItemType.LOST;
  category: ItemCategory = ItemCategory.OTHER;
  title: string = '';
  description: string = '';
  location: string = '';
  contact: string = '';
  images: string[] = [];
  publisherId: string = '';
  publisherName: string = '';
  publisherAvatar: string = '';
  status: ItemStatus = ItemStatus.ACTIVE;
  publishTime: number = 0;
  updateTime: number = 0;
  viewCount: number = 0;
  claimTime: number = 0;
  isMine: boolean = false;
}

export class ItemQueryParams {
  type?: number;
  category?: number;
  status?: number;
  keyword?: string;
  pageNum: number = 1;
  pageSize: number = 20;
  sortBy: string = 'publishTime';
  sortOrder: string = 'desc';
}

export class PublishItemRequest {
  type: ItemType = ItemType.LOST;
  category: ItemCategory = ItemCategory.CARD;
  title: string = '';
  description: string = '';
  location: string = '';
  contact: string = '';
  images: string[] = [];
}

export class LatestItem {
  id: string = '';
  type: ItemType = ItemType.LOST;
  title: string = '';
  publishTime: number = 0;
}

export class ResolveResult {
  status: number = 0;
  claimTime: number = 0;
}

export class UpdateItemRequest {
  type?: ItemType = undefined;
  category?: ItemCategory = undefined;
  title?: string = '';
  description?: string = '';
  location?: string = '';
  contact?: string = '';
  images?: string[] = [];
}
