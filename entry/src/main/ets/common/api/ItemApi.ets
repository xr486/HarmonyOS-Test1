import { HttpUtil } from './HttpUtil';
import { ApiResult, PageResult } from '../model/ApiResult';
import {
  LostFoundItem,
  ItemQueryParams,
  PublishItemRequest,
  LatestItem,
  ResolveResult
} from '../model/ItemModel';

export class ItemApi {
  private static http = HttpUtil.getInstance();

  static getItemList(params: ItemQueryParams): Promise<ApiResult<PageResult<LostFoundItem>>> {
    const queryParams: Record<string, string | number | boolean> = {};
    if (params.type !== undefined) queryParams.type = params.type;
    if (params.category !== undefined) queryParams.category = params.category;
    if (params.status !== undefined) queryParams.status = params.status;
    if (params.keyword) queryParams.keyword = params.keyword;
    queryParams.pageNum = params.pageNum;
    queryParams.pageSize = params.pageSize;
    queryParams.sortBy = params.sortBy;
    queryParams.sortOrder = params.sortOrder;
    return this.http.get<PageResult<LostFoundItem>>('/items', queryParams, false);
  }

  static getItemDetail(id: string): Promise<ApiResult<LostFoundItem>> {
    return this.http.get<LostFoundItem>(`/items/${id}`, undefined, false);
  }

  static publishItem(data: PublishItemRequest): Promise<ApiResult<{ id: string; publishTime: number }>> {
    return this.http.post<{ id: string; publishTime: number }>('/items', data, true);
  }

  static updateItem(id: string, data: Partial<PublishItemRequest>): Promise<ApiResult<null>> {
    return this.http.put<null>(`/items/${id}`, data, true);
  }

  static deleteItem(id: string): Promise<ApiResult<null>> {
    return this.http.delete<null>(`/items/${id}`, undefined, true);
  }

  static resolveItem(id: string): Promise<ApiResult<ResolveResult>> {
    return this.http.put<ResolveResult>(`/items/${id}/resolve`, undefined, true);
  }

  static getLatestItems(count: number = 5): Promise<ApiResult<LatestItem[]>> {
    return this.http.get<LatestItem[]>('/items/latest', { count }, false);
  }

  static getMyItems(status: number = -1, pageNum: number = 1, pageSize: number = 20): Promise<ApiResult<PageResult<LostFoundItem>>> {
    const queryParams: Record<string, string | number | boolean> = {
      status,
      pageNum,
      pageSize
    };
    return this.http.get<PageResult<LostFoundItem>>('/items/my', queryParams, true);
  }
}
