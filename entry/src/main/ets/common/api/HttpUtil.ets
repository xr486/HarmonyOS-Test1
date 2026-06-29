import http from '@ohos.net.http';
import { TokenUtil } from '../utils/TokenUtil';
import { ApiResult } from '../model/ApiResult';
import promptAction from '@ohos.promptAction';

const BASE_URL = 'https://api.campus-lostandfound.com/api/v1';
const DEFAULT_TIMEOUT = 15000;

export enum HttpMethod {
  GET = http.RequestMethod.GET,
  POST = http.RequestMethod.POST,
  PUT = http.RequestMethod.PUT,
  DELETE = http.RequestMethod.DELETE
}

export interface RequestOptions {
  url: string;
  method: HttpMethod;
  data?: object;
  params?: Record<string, string | number | boolean>;
  needAuth?: boolean;
  showLoading?: boolean;
  showError?: boolean;
  timeout?: number;
}

export class HttpUtil {
  private static instance: HttpUtil | null = null;

  private constructor() {}

  public static getInstance(): HttpUtil {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil();
    }
    return HttpUtil.instance;
  }

  private buildUrl(url: string, params?: Record<string, string | number | boolean>): string {
    let fullUrl = url.startsWith('http') ? url : BASE_URL + url;
    if (params && Object.keys(params).length > 0) {
      const queryString = Object.keys(params)
        .filter(key => params[key] !== undefined && params[key] !== null && params[key] !== '')
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
        .join('&');
      if (queryString) {
        fullUrl += (fullUrl.includes('?') ? '&' : '?') + queryString;
      }
    }
    return fullUrl;
  }

  private buildHeaders(needAuth: boolean = false): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json'
    };
    if (needAuth) {
      const token = TokenUtil.getInstance().getToken();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }
    return headers;
  }

  private parseResponse<T>(response: http.HttpResponse): ApiResult<T> {
    const result: ApiResult<T> = new ApiResult<T>();
    try {
      if (typeof response.result === 'string') {
        const parsed = JSON.parse(response.result);
        result.code = parsed.code || 0;
        result.message = parsed.message || '';
        result.data = parsed.data !== undefined ? parsed.data : null;
        result.timestamp = parsed.timestamp || Date.now();
      } else if (response.result && typeof response.result === 'object') {
        const parsed = response.result as Record<string, Object>;
        result.code = (parsed.code as number) || 0;
        result.message = (parsed.message as string) || '';
        result.data = parsed.data !== undefined ? (parsed.data as T) : null;
        result.timestamp = (parsed.timestamp as number) || Date.now();
      }
    } catch (e) {
      console.error('[HttpUtil] parseResponse error:', JSON.stringify(e));
      result.code = -1;
      result.message = '数据解析失败';
      result.data = null;
      result.timestamp = Date.now();
    }
    return result;
  }

  private handleError(error: Error, showError: boolean = true): ApiResult<null> {
    console.error('[HttpUtil] request error:', error.message);
    const result: ApiResult<null> = new ApiResult<null>();
    result.code = -1;
    result.message = '网络请求失败，请检查网络连接';
    result.data = null;
    result.timestamp = Date.now();
    if (showError) {
      try {
        promptAction.showToast({ message: result.message, duration: 2000 });
      } catch (e) {
        console.error('[HttpUtil] showToast error:', JSON.stringify(e));
      }
    }
    return result;
  }

  private handleBusinessError<T>(result: ApiResult<T>, showError: boolean = true): void {
    if (result.code !== 200 && showError && result.message) {
      try {
        promptAction.showToast({ message: result.message, duration: 2000 });
      } catch (e) {
        console.error('[HttpUtil] showBusinessError toast error:', JSON.stringify(e));
      }
    }
    if (result.code === 401) {
      TokenUtil.getInstance().clearToken();
    }
  }

  async request<T>(options: RequestOptions): Promise<ApiResult<T>> {
    const {
      url,
      method,
      data,
      params,
      needAuth = false,
      showError = true,
      timeout = DEFAULT_TIMEOUT
    } = options;

    let httpRequest: http.HttpRequest | null = null;

    try {
      httpRequest = http.createHttp();
      const fullUrl = this.buildUrl(url, params);
      const headers = this.buildHeaders(needAuth);

      console.log('[HttpUtil] request:', method, fullUrl);

      const response = await httpRequest.request(fullUrl, {
        method: method,
        header: headers,
        extraData: data,
        connectTimeout: timeout,
        readTimeout: timeout
      });

      const result = this.parseResponse<T>(response);

      if (result.code !== 200) {
        this.handleBusinessError(result, showError);
      }

      return result;
    } catch (error) {
      return this.handleError(error as Error, showError);
    } finally {
      if (httpRequest) {
        try {
          httpRequest.destroy();
        } catch (e) {
          console.error('[HttpUtil] destroy error:', JSON.stringify(e));
        }
      }
    }
  }

  get<T>(url: string, params?: Record<string, string | number | boolean>, needAuth: boolean = false): Promise<ApiResult<T>> {
    return this.request<T>({
      url,
      method: HttpMethod.GET,
      params,
      needAuth
    });
  }

  post<T>(url: string, data?: object, needAuth: boolean = false): Promise<ApiResult<T>> {
    return this.request<T>({
      url,
      method: HttpMethod.POST,
      data,
      needAuth
    });
  }

  put<T>(url: string, data?: object, needAuth: boolean = false): Promise<ApiResult<T>> {
    return this.request<T>({
      url,
      method: HttpMethod.PUT,
      data,
      needAuth
    });
  }

  delete<T>(url: string, params?: Record<string, string | number | boolean>, needAuth: boolean = false): Promise<ApiResult<T>> {
    return this.request<T>({
      url,
      method: HttpMethod.DELETE,
      params,
      needAuth
    });
  }
}
