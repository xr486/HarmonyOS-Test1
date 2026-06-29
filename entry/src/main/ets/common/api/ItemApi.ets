import { HttpUtil } from './HttpUtil';
import { ApiResult, PageResult } from '../model/ApiResult';
import {
  LostFoundItem,
  ItemQueryParams,
  PublishItemRequest,
  LatestItem,
  ResolveResult
} from '../model/ItemModel';

/**
 * 发布物品返回结果
 */
export class PublishResult {
  id: string = '';
  publishTime: number = 0;
}

export class ItemApi {
  static getItemList(params: ItemQueryParams): Promise<ApiResult<PageResult<LostFoundItem>>> {
    const http: HttpUtil = HttpUtil.getInstance();
    const queryParams: Record<string, string | number | boolean> = {};
    if (params.type !== undefined) {
      queryParams['type'] = params.type;
    }
    if (params.category !== undefined) {
      queryParams['category'] = params.category;
    }
    if (params.status !== undefined) {
      queryParams['status'] = params.status;
    }
    if (params.keyword) {
      queryParams['keyword'] = params.keyword;
    }
    queryParams['pageNum'] = params.pageNum;
    queryParams['pageSize'] = params.pageSize;
    queryParams['sortBy'] = params.sortBy;
    queryParams['sortOrder'] = params.sortOrder;
    return http.get<PageResult<LostFoundItem>>('/items', queryParams, false);
  }

  static getItemDetail(id: string): Promise<ApiResult<LostFoundItem>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.get<LostFoundItem>(`/items/${id}`, undefined, false);
  }

  static publishItem(data: PublishItemRequest): Promise<ApiResult<PublishResult>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.post<PublishResult>('/items', data, true);
  }

  static updateItem(id: string, data: PublishItemRequest): Promise<ApiResult<Object>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.put<Object>(`/items/${id}`, data, true);
  }

  static deleteItem(id: string): Promise<ApiResult<Object>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.delete<Object>(`/items/${id}`, undefined, true);
  }

  static resolveItem(id: string): Promise<ApiResult<ResolveResult>> {
    const http: HttpUtil = HttpUtil.getInstance();
    return http.put<ResolveResult>(`/items/${id}/resolve`, undefined, true);
  }

  static getLatestItems(count: number = 5): Promise<ApiResult<LatestItem[]>> {
    const http: HttpUtil = HttpUtil.getInstance();
    const params: Record<string, string | number | boolean> = {
      'count': count
    };
    return http.get<LatestItem[]>('/items/latest', params, false);
  }

  static getMyItems(status: number = -1, pageNum: number = 1, pageSize: number = 20): Promise<ApiResult<PageResult<LostFoundItem>>> {
    const http: HttpUtil = HttpUtil.getInstance();
    const queryParams: Record<string, string | number | boolean> = {
      'status': status,
      'pageNum': pageNum,
      'pageSize': pageSize
    };
    return http.get<PageResult<LostFoundItem>>('/items/my', queryParams, true);
  }
}
