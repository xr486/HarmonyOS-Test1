export enum ItemType {
  LOST = 0,
  FOUND = 1
}

export enum ItemCategory {
  ALL = 0,
  CARD = 1,
  DIGITAL = 2,
  CLOTHING = 3,
  BOOK = 4,
  OTHER = 5
}

export enum ItemStatus {
  ACTIVE = 0,
  CLAIMED = 1,
  RETURNED = 2
}

@Observed
export class LostFoundItem {
  id: string = '';
  type: ItemType = ItemType.LOST;
  category: ItemCategory = ItemCategory.ALL;
  title: string = '';
  description: string = '';
  location: string = '';
  contact: string = '';
  images: string[] = [];
  publishTime: number = 0;
  publisherId: string = '';
  publisherName: string = '';
  status: ItemStatus = ItemStatus.ACTIVE;
  viewCount: number = 0;
  isMine: boolean = false;
  updateTime: number = 0;
}

export function getCategoryName(category: ItemCategory): string {
  switch (category) {
    case ItemCategory.CARD:
      return '证件卡片';
    case ItemCategory.DIGITAL:
      return '数码产品';
    case ItemCategory.CLOTHING:
      return '衣物服饰';
    case ItemCategory.BOOK:
      return '书籍文具';
    case ItemCategory.OTHER:
      return '其他物品';
    default:
      return '全部';
  }
}

export function getStatusText(status: ItemStatus, type: ItemType): string {
  if (status === ItemStatus.ACTIVE) {
    return '进行中';
  } else if (type === ItemType.LOST) {
    return '已寻回';
  } else {
    return '已认领';
  }
}

export function formatTime(timestamp: number): string {
  const date = new Date(timestamp);
  const now = new Date();
  const diff = now.getTime() - timestamp;
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;

  if (diff < minute) {
    return '刚刚';
  } else if (diff < hour) {
    return `${Math.floor(diff / minute)}分钟前`;
  } else if (diff < day) {
    return `${Math.floor(diff / hour)}小时前`;
  } else if (diff < 7 * day) {
    return `${Math.floor(diff / day)}天前`;
  } else {
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }
}
