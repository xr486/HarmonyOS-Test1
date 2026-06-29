import { LostFoundItem, ItemType, ItemCategory, ItemStatus } from '../bean/LostFoundItem';
import { UserInfo } from '../bean/UserInfo';
import { ItemApi } from '../api/ItemApi';
import { PageResult, ApiResult } from '../model/ApiResult';
import { UserStore } from '../store/UserStore';
import { PublishItemRequest, UpdateItemRequest } from '../model/ItemModel';

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

interface ListCache {
  items: LostFoundItem[];
  total: number;
  pageNum: number;
  pageSize: number;
  totalPages: number;
  expireTime: number;
}

interface ListCacheKey {
  type?: ItemType;
  category?: ItemCategory;
  status?: number;
  keyword?: string;
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
  dataVersion: number = 0;
  useApi: boolean = true;

  private listCache: Map<string, ListCache> = new Map();
  private detailCache: Map<string, { item: LostFoundItem; expireTime: number }> = new Map();
  private myItemsCache: ListCache | null = null;
  private readonly CACHE_DURATION: number = 5 * 60 * 1000;

  private userStore: UserStore = UserStore.getInstance();

  private constructor() {
    AppStorage.setOrCreate('globalDataVersion', 1);
    this.dataVersion = 1;
    this.currentUser = this.userStore.getUserInfo();
  }

  public static getInstance(): AppViewModel {
    if (!AppViewModel.instance) {
      AppViewModel.instance = new AppViewModel();
    }
    return AppViewModel.instance;
  }

  private generateCacheKey(params: ListCacheKey): string {
    return JSON.stringify(params);
  }

  private isCacheExpired(expireTime: number): boolean {
    return Date.now() > expireTime;
  }

  async getItemList(
    type?: ItemType,
    category?: ItemCategory,
    status?: number,
    keyword?: string,
    pageNum: number = 1,
    pageSize: number = 20,
    forceRefresh: boolean = false
  ): Promise<{ list: LostFoundItem[]; total: number; hasMore: boolean }> {
    const cacheKey = this.generateCacheKey({ type, category, status, keyword });
    const now = Date.now();

    if (!forceRefresh && this.useApi) {
      const cached = this.listCache.get(cacheKey);
      if (cached && cached.pageNum >= pageNum && !this.isCacheExpired(cached.expireTime)) {
        const end = pageNum * pageSize;
        const list = cached.items.slice(0, end);
        return {
          list: list,
          total: cached.total,
          hasMore: end < cached.items.length || list.length < cached.total
        };
      }
    }

    try {
      if (this.useApi) {
        const result: ApiResult<PageResult<LostFoundItem>> = await ItemApi.getItemList(
          type, category, status, keyword, pageNum, pageSize
        );

        if (result.code === 200 && result.data) {
          const data = result.data;
          const existingCache = this.listCache.get(cacheKey);

          if (pageNum === 1 || !existingCache) {
            this.listCache.set(cacheKey, {
              items: data.list,
              total: data.total,
              pageNum: data.pageNum,
              pageSize: data.pageSize,
              totalPages: data.totalPages,
              expireTime: now + this.CACHE_DURATION
            });
          } else {
            const mergedItems = existingCache.items.concat(data.list);
            existingCache.items = mergedItems;
            existingCache.pageNum = data.pageNum;
            existingCache.total = data.total;
            existingCache.totalPages = data.totalPages;
            existingCache.expireTime = now + this.CACHE_DURATION;
          }

          const cache = this.listCache.get(cacheKey)!;
          const end = pageNum * pageSize;
          return {
            list: cache.items.slice(0, end),
            total: cache.total,
            hasMore: cache.items.length < cache.total
          };
        }
      }

      this.items = this.getFilteredItems();
      const end = pageNum * pageSize;
      return {
        list: this.items.slice(0, end),
        total: this.items.length,
        hasMore: end < this.items.length
      };
    } catch (e) {
      console.error('[AppViewModel] getItemList error:', JSON.stringify(e));
      return { list: [], total: 0, hasMore: false };
    }
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

  async getLatestItems(count: number = 5): Promise<LostFoundItem[]> {
    try {
      if (this.useApi) {
        const result = await this.getItemList(undefined, undefined, 0, '', 1, count, false);
        return result.list.slice(0, count);
      }
    } catch (e) {
      console.error('[AppViewModel] getLatestItems error:', JSON.stringify(e));
    }

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

  async getMyPublishedItems(
    status?: number,
    pageNum: number = 1,
    pageSize: number = 20,
    forceRefresh: boolean = false
  ): Promise<{ list: LostFoundItem[]; total: number; hasMore: boolean }> {
    const now = Date.now();

    if (!forceRefresh && this.useApi && this.myItemsCache && !this.isCacheExpired(this.myItemsCache.expireTime)) {
      const end = pageNum * pageSize;
      return {
        list: this.myItemsCache.items.slice(0, end),
        total: this.myItemsCache.total,
        hasMore: end < this.myItemsCache.items.length
      };
    }

    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const result = await ItemApi.getMyItems(status, pageNum, pageSize);
        if (result.code === 200 && result.data) {
          const data = result.data;
          if (pageNum === 1 || !this.myItemsCache) {
            this.myItemsCache = {
              items: data.list,
              total: data.total,
              pageNum: data.pageNum,
              pageSize: data.pageSize,
              totalPages: data.totalPages,
              expireTime: now + this.CACHE_DURATION
            };
          } else {
            this.myItemsCache.items = this.myItemsCache.items.concat(data.list);
            this.myItemsCache.pageNum = data.pageNum;
            this.myItemsCache.total = data.total;
            this.myItemsCache.totalPages = data.totalPages;
            this.myItemsCache.expireTime = now + this.CACHE_DURATION;
          }

          const end = pageNum * pageSize;
          return {
            list: this.myItemsCache.items.slice(0, end),
            total: this.myItemsCache.total,
            hasMore: this.myItemsCache.items.length < this.myItemsCache.total
          };
        }
      }
    } catch (e) {
      console.error('[AppViewModel] getMyPublishedItems error:', JSON.stringify(e));
    }

    if (!this.currentUser) {
      return { list: [], total: 0, hasMore: false };
    }
    const result: LostFoundItem[] = [];
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].publisherId === this.currentUser.id) {
        if (status !== undefined && status >= 0 && this.items[i].status !== status) {
          continue;
        }
        result.push(this.items[i]);
      }
    }
    result.sort((a: LostFoundItem, b: LostFoundItem) => b.publishTime - a.publishTime);
    return { list: result, total: result.length, hasMore: false };
  }

  async getItemById(id: string, forceRefresh: boolean = false): Promise<LostFoundItem | undefined> {
    if (!forceRefresh) {
      const cached = this.detailCache.get(id);
      if (cached && !this.isCacheExpired(cached.expireTime)) {
        return cached.item;
      }
    }

    try {
      if (this.useApi) {
        const result = await ItemApi.getItemDetail(id);
        if (result.code === 200 && result.data) {
          this.detailCache.set(id, {
            item: result.data as LostFoundItem,
            expireTime: Date.now() + this.CACHE_DURATION
          });
          return result.data as LostFoundItem;
        }
      }
    } catch (e) {
      console.error('[AppViewModel] getItemById error:', JSON.stringify(e));
    }

    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].id === id) {
        return this.items[i];
      }
    }
    return undefined;
  }

  private clearListCache(): void {
    this.listCache.clear();
    this.myItemsCache = null;
  }

  private clearDetailCache(id?: string): void {
    if (id) {
      this.detailCache.delete(id);
    } else {
      this.detailCache.clear();
    }
  }

  async addItem(item: NewLostFoundItem): Promise<boolean> {
    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const request: PublishItemRequest = new PublishItemRequest();
        request.type = item.type;
        request.category = item.category;
        request.title = item.title;
        request.description = item.description;
        request.location = item.location;
        request.contact = item.contact;
        request.images = item.images;

        const result = await ItemApi.publishItem(request);
        if (result.code === 200) {
          this.clearListCache();
          this.dataVersion++;
          AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
          return true;
        }
        return false;
      }
    } catch (e) {
      console.error('[AppViewModel] addItem error:', JSON.stringify(e));
    }

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
    this.dataVersion++;
    AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
    return true;
  }

  async updateItem(id: string, updates: PartialLostFoundItem): Promise<boolean> {
    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const request: UpdateItemRequest = {
          type: updates.type,
          category: updates.category,
          title: updates.title,
          description: updates.description,
          location: updates.location,
          contact: updates.contact,
          images: updates.images
        };

        const result = await ItemApi.updateItem(id, request);
        if (result.code === 200) {
          this.clearListCache();
          this.clearDetailCache(id);
          this.dataVersion++;
          AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
          return true;
        }
        return false;
      }
    } catch (e) {
      console.error('[AppViewModel] updateItem error:', JSON.stringify(e));
    }

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
      this.dataVersion++;
      AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
    }
    return true;
  }

  async removeItem(id: string): Promise<boolean> {
    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const result = await ItemApi.deleteItem(id);
        if (result.code === 200) {
          this.clearListCache();
          this.clearDetailCache(id);
          this.dataVersion++;
          AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
          return true;
        }
        return false;
      }
    } catch (e) {
      console.error('[AppViewModel] removeItem error:', JSON.stringify(e));
    }

    const index = this.items.findIndex((item: LostFoundItem) => item.id === id);
    if (index !== -1) {
      this.items.splice(index, 1);
      this.dataVersion++;
      AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
    }
    return true;
  }

  async markAsResolved(id: string): Promise<boolean> {
    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const result = await ItemApi.resolveItem(id);
        if (result.code === 200) {
          this.clearListCache();
          this.clearDetailCache(id);
          this.dataVersion++;
          AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
          return true;
        }
        return false;
      }
    } catch (e) {
      console.error('[AppViewModel] markAsResolved error:', JSON.stringify(e));
    }

    const item = this.items.find((i: LostFoundItem) => i.id === id);
    if (item) {
      item.status = item.type === ItemType.LOST ? ItemStatus.RETURNED : ItemStatus.CLAIMED;
      this.dataVersion++;
      AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
    }
    return true;
  }

  login(user: UserInfo): void {
    this.currentUser = user;
    this.dataVersion++;
    AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
  }

  logout(): void {
    this.currentUser = null;
    this.clearListCache();
    this.clearDetailCache();
    this.myItemsCache = null;
    this.dataVersion++;
    AppStorage.setOrCreate('globalDataVersion', this.dataVersion);
  }

  isLoggedIn(): boolean {
    return this.userStore.isLoggedIn || this.currentUser !== null;
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