import { LostFoundItem, ItemType, ItemCategory, ItemStatus } from '../bean/LostFoundItem';
import { UserInfo } from '../bean/UserInfo';
import { ItemApi, PublishResult } from '../api/ItemApi';
import { PageResult, ApiResult } from '../model/ApiResult';
import { UserStore } from '../store/UserStore';
import { PublishItemRequest, ItemQueryParams } from '../model/ItemModel';

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

export class ItemListResult {
  list: LostFoundItem[] = [];
  total: number = 0;
  hasMore: boolean = false;
}

export class ListCache {
  items: LostFoundItem[] = [];
  total: number = 0;
  pageNum: number = 0;
  pageSize: number = 0;
  totalPages: number = 0;
  expireTime: number = 0;
}

export class DetailCache {
  item: LostFoundItem = new LostFoundItem();
  expireTime: number = 0;
}

export class PartialLostFoundItem {
  type?: ItemType = undefined;
  category?: ItemCategory = undefined;
  title?: string = '';
  description?: string = '';
  location?: string = '';
  contact?: string = '';
  images?: string[] = [];
  status?: ItemStatus = undefined;
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
  private detailCache: Map<string, DetailCache> = new Map();
  private myItemsCache: ListCache | null = null;
  private readonly CACHE_DURATION: number = 5 * 60 * 1000;

  private userStore: UserStore = UserStore.getInstance();

  private constructor() {
    AppStorage.setOrCreate('globalDataVersion', 1);
    this.dataVersion = 1;
    const userInfo: UserInfo | null = this.userStore.getUserInfo();
    this.currentUser = userInfo;
  }

  public static getInstance(): AppViewModel {
    if (!AppViewModel.instance) {
      AppViewModel.instance = new AppViewModel();
    }
    return AppViewModel.instance;
  }

  private generateCacheKey(type?: ItemType, category?: ItemCategory, status?: number, keyword?: string): string {
    let key = '';
    if (type !== undefined) {
      key += 't' + type;
    }
    if (category !== undefined) {
      key += 'c' + category;
    }
    if (status !== undefined) {
      key += 's' + status;
    }
    if (keyword !== undefined && keyword.length > 0) {
      key += 'k' + keyword;
    }
    return key;
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
  ): Promise<ItemListResult> {
    const cacheKey = this.generateCacheKey(type, category, status, keyword);
    const now = Date.now();
    const result: ItemListResult = new ItemListResult();

    if (!forceRefresh && this.useApi) {
      const cached = this.listCache.get(cacheKey);
      if (cached && cached.pageNum >= pageNum && !this.isCacheExpired(cached.expireTime)) {
        const end = pageNum * pageSize;
        result.list = cached.items.slice(0, end);
        result.total = cached.total;
        result.hasMore = end < cached.items.length || result.list.length < cached.total;
        return result;
      }
    }

    try {
      if (this.useApi) {
        const params: ItemQueryParams = new ItemQueryParams();
        if (type !== undefined) {
          params.type = type;
        }
        if (category !== undefined) {
          params.category = category;
        }
        if (status !== undefined) {
          params.status = status;
        }
        if (keyword !== undefined) {
          params.keyword = keyword;
        }
        params.pageNum = pageNum;
        params.pageSize = pageSize;
        params.sortBy = 'publishTime';
        params.sortOrder = 'desc';

        const apiResult: ApiResult<PageResult<LostFoundItem>> = await ItemApi.getItemList(params);

        if (apiResult.code === 200 && apiResult.data) {
          const data = apiResult.data as PageResult<LostFoundItem>;
          const existingCache = this.listCache.get(cacheKey);

          if (pageNum === 1 || !existingCache) {
            const cacheData: ListCache = new ListCache();
            cacheData.items = data.list;
            cacheData.total = data.total;
            cacheData.pageNum = data.pageNum;
            cacheData.pageSize = data.pageSize;
            cacheData.totalPages = data.totalPages;
            cacheData.expireTime = now + this.CACHE_DURATION;
            this.listCache.set(cacheKey, cacheData);
          } else {
            const mergedItems = existingCache.items.concat(data.list);
            existingCache.items = mergedItems;
            existingCache.pageNum = data.pageNum;
            existingCache.total = data.total;
            existingCache.totalPages = data.totalPages;
            existingCache.expireTime = now + this.CACHE_DURATION;
          }

          const cache = this.listCache.get(cacheKey);
          if (cache) {
            const end = pageNum * pageSize;
            result.list = cache.items.slice(0, end);
            result.total = cache.total;
            result.hasMore = cache.items.length < cache.total;
            return result;
          }
        }
      }

      this.items = this.getFilteredItems();
      const end = pageNum * pageSize;
      result.list = this.items.slice(0, end);
      result.total = this.items.length;
      result.hasMore = end < this.items.length;
      return result;
    } catch (e) {
      console.error('[AppViewModel] getItemList error:', JSON.stringify(e));
      return result;
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
  ): Promise<ItemListResult> {
    const now = Date.now();
    const result: ItemListResult = new ItemListResult();

    if (!forceRefresh && this.useApi && this.myItemsCache && !this.isCacheExpired(this.myItemsCache.expireTime)) {
      const end = pageNum * pageSize;
      result.list = this.myItemsCache.items.slice(0, end);
      result.total = this.myItemsCache.total;
      result.hasMore = end < this.myItemsCache.items.length;
      return result;
    }

    try {
      if (this.useApi && this.userStore.isLoggedIn) {
        const statusVal = status !== undefined ? status : -1;
        const apiResult = await ItemApi.getMyItems(statusVal, pageNum, pageSize);
        if (apiResult.code === 200 && apiResult.data) {
          const data = apiResult.data as PageResult<LostFoundItem>;
          if (pageNum === 1 || !this.myItemsCache) {
            const cache = new ListCache();
            cache.items = data.list;
            cache.total = data.total;
            cache.pageNum = data.pageNum;
            cache.pageSize = data.pageSize;
            cache.totalPages = data.totalPages;
            cache.expireTime = now + this.CACHE_DURATION;
            this.myItemsCache = cache;
          } else {
            this.myItemsCache.items = this.myItemsCache.items.concat(data.list);
            this.myItemsCache.pageNum = data.pageNum;
            this.myItemsCache.total = data.total;
            this.myItemsCache.totalPages = data.totalPages;
            this.myItemsCache.expireTime = now + this.CACHE_DURATION;
          }

          const end = pageNum * pageSize;
          result.list = this.myItemsCache.items.slice(0, end);
          result.total = this.myItemsCache.total;
          result.hasMore = this.myItemsCache.items.length < this.myItemsCache.total;
          return result;
        }
      }
    } catch (e) {
      console.error('[AppViewModel] getMyPublishedItems error:', JSON.stringify(e));
    }

    if (!this.currentUser) {
      return result;
    }
    const myItems: LostFoundItem[] = [];
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].publisherId === this.currentUser.id) {
        if (status !== undefined && status >= 0 && this.items[i].status !== status) {
          continue;
        }
        myItems.push(this.items[i]);
      }
    }
    myItems.sort((a: LostFoundItem, b: LostFoundItem) => b.publishTime - a.publishTime);
    result.list = myItems;
    result.total = myItems.length;
    result.hasMore = false;
    return result;
  }

  async getItemById(id: string, forceRefresh: boolean = false): Promise<LostFoundItem | null> {
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
          const cacheData: DetailCache = new DetailCache();
          cacheData.item = result.data as LostFoundItem;
          cacheData.expireTime = Date.now() + this.CACHE_DURATION;
          this.detailCache.set(id, cacheData);
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
    return null;
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

        const result: ApiResult<PublishResult> = await ItemApi.publishItem(request);
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
        const request: PublishItemRequest = new PublishItemRequest();
        if (updates.type !== undefined) {
          request.type = updates.type;
        }
        if (updates.category !== undefined) {
          request.category = updates.category;
        }
        if (updates.title !== undefined) {
          request.title = updates.title;
        }
        if (updates.description !== undefined) {
          request.description = updates.description;
        }
        if (updates.location !== undefined) {
          request.location = updates.location;
        }
        if (updates.contact !== undefined) {
          request.contact = updates.contact;
        }
        if (updates.images !== undefined) {
          request.images = updates.images;
        }

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
