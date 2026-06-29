import { LostFoundItem, ItemType, ItemCategory, ItemStatus } from '../bean/LostFoundItem';
import { UserInfo } from '../bean/UserInfo';
import { generateMockData } from '../mock/MockData';

export class NewLostFoundItem {
  type: ItemType = ItemType.LOST;
  category: ItemCategory = ItemCategory.ALL;
  title: string = '';
  description: string = '';
  location: string = '';
  contact: string = '';
  images: string[] = [];
  publisherId: string = '';
  publisherName: string = '';
}

@Observed
export class AppViewModel {
  private static instance: AppViewModel | null = null;
  items: LostFoundItem[] = [];
  currentUser: UserInfo | null = null;
  currentTab: number = 0;
  searchKeyword: string = '';
  selectedType: ItemType = ItemType.LOST;
  selectedCategory: ItemCategory = ItemCategory.ALL;

  private constructor() {
    this.items = generateMockData();
  }

  public static getInstance(): AppViewModel {
    if (!AppViewModel.instance) {
      AppViewModel.instance = new AppViewModel();
    }
    return AppViewModel.instance;
  }

  getFilteredItems(): LostFoundItem[] {
    const result: LostFoundItem[] = [];
    for (let i = 0; i < this.items.length; i++) {
      const item = this.items[i];
      if (this.selectedCategory !== ItemCategory.ALL && item.category !== this.selectedCategory) {
        continue;
      }
      if (item.type !== this.selectedType) {
        continue;
      }
      if (this.searchKeyword && this.searchKeyword.trim().length > 0) {
        const keyword = this.searchKeyword.toLowerCase();
        const titleMatch = item.title.toLowerCase().includes(keyword);
        const descMatch = item.description.toLowerCase().includes(keyword);
        const locMatch = item.location.toLowerCase().includes(keyword);
        if (!titleMatch && !descMatch && !locMatch) {
          continue;
        }
      }
      result.push(item);
    }
    result.sort((a: LostFoundItem, b: LostFoundItem) => b.publishTime - a.publishTime);
    return result;
  }

  getLatestItems(count: number = 5): LostFoundItem[] {
    const result: LostFoundItem[] = [];
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].status === ItemStatus.ACTIVE) {
        result.push(this.items[i]);
      }
    }
    result.sort((a: LostFoundItem, b: LostFoundItem) => b.publishTime - a.publishTime);
    if (result.length > count) {
      return result.slice(0, count);
    }
    return result;
  }

  getMyPublishedItems(): LostFoundItem[] {
    if (!this.currentUser) {
      return [];
    }
    const result: LostFoundItem[] = [];
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].publisherId === this.currentUser.id) {
        result.push(this.items[i]);
      }
    }
    result.sort((a: LostFoundItem, b: LostFoundItem) => b.publishTime - a.publishTime);
    return result;
  }

  getItemById(id: string): LostFoundItem | undefined {
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].id === id) {
        return this.items[i];
      }
    }
    return undefined;
  }

  addItem(item: NewLostFoundItem): void {
    const newItem: LostFoundItem = new LostFoundItem();
    newItem.id = Date.now().toString();
    newItem.type = item.type;
    newItem.category = item.category;
    newItem.title = item.title;
    newItem.description = item.description;
    newItem.location = item.location;
    newItem.contact = item.contact;
    newItem.images = item.images;
    newItem.publisherId = item.publisherId;
    newItem.publisherName = item.publisherName;
    newItem.publishTime = Date.now();
    newItem.status = ItemStatus.ACTIVE;
    this.items.unshift(newItem);
  }

  updateItem(id: string, updates: PartialLostFoundItem): void {
    const index = this.items.findIndex((item: LostFoundItem) => item.id === id);
    if (index !== -1) {
      const oldItem = this.items[index];
      const newItem: LostFoundItem = new LostFoundItem();
      newItem.id = oldItem.id;
      newItem.type = updates.type !== undefined ? updates.type : oldItem.type;
      newItem.category = updates.category !== undefined ? updates.category : oldItem.category;
      newItem.title = updates.title !== undefined ? updates.title : oldItem.title;
      newItem.description = updates.description !== undefined ? updates.description : oldItem.description;
      newItem.location = updates.location !== undefined ? updates.location : oldItem.location;
      newItem.contact = updates.contact !== undefined ? updates.contact : oldItem.contact;
      newItem.images = updates.images !== undefined ? updates.images : oldItem.images;
      newItem.publisherId = oldItem.publisherId;
      newItem.publisherName = oldItem.publisherName;
      newItem.publishTime = oldItem.publishTime;
      newItem.status = updates.status !== undefined ? updates.status : oldItem.status;
      this.items[index] = newItem;
    }
  }

  removeItem(id: string): void {
    const index = this.items.findIndex((item: LostFoundItem) => item.id === id);
    if (index !== -1) {
      this.items.splice(index, 1);
    }
  }

  markAsResolved(id: string): void {
    const item = this.getItemById(id);
    if (item) {
      item.status = item.type === ItemType.LOST ? ItemStatus.RETURNED : ItemStatus.CLAIMED;
    }
  }

  login(user: UserInfo): void {
    this.currentUser = user;
  }

  logout(): void {
    this.currentUser = null;
  }

  isLoggedIn(): boolean {
    return this.currentUser !== null;
  }
}

export interface PartialLostFoundItem {
  type?: ItemType;
  category?: ItemCategory;
  title?: string;
  description?: string;
  location?: string;
  contact?: string;
  images?: string[];
  status?: ItemStatus;
}
