import { UploadResult } from '../model/UploadModel';
import { ApiResult } from '../model/ApiResult';
import { TokenUtil } from '../utils/TokenUtil';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

const BASE_URL = 'https://api.campus-lostandfound.com/api/v1';

export class UploadApi {
  static async uploadImage(filePath: string, type: string = 'item'): Promise<ApiResult<UploadResult>> {
    let httpRequest: http.HttpRequest | null = null;
    const result: ApiResult<UploadResult> = new ApiResult<UploadResult>();

    try {
      httpRequest = http.createHttp();
      const token = TokenUtil.getInstance().getToken();

      const response = await httpRequest.request(`${BASE_URL}/upload/image`, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': `Bearer ${token}`
        },
        extraData: {
          name: 'file',
          uri: filePath,
          type: type
        }
      });

      if (typeof response.result === 'string') {
        const parsed = JSON.parse(response.result);
        result.code = parsed.code || 0;
        result.message = parsed.message || '';
        result.data = parsed.data || null;
        result.timestamp = parsed.timestamp || Date.now();
      }

      if (result.code !== 200 && result.message) {
        promptAction.showToast({ message: result.message, duration: 2000 });
      }

      return result;
    } catch (error) {
      console.error('[UploadApi] uploadImage error:', JSON.stringify(error));
      result.code = -1;
      result.message = '上传失败，请重试';
      result.data = null;
      result.timestamp = Date.now();
      promptAction.showToast({ message: result.message, duration: 2000 });
      return result;
    } finally {
      if (httpRequest) {
        try {
          httpRequest.destroy();
        } catch (e) {
          console.error('[UploadApi] destroy error:', JSON.stringify(e));
        }
      }
    }
  }

  static async deleteImage(url: string): Promise<ApiResult<null>> {
    const result: ApiResult<null> = new ApiResult<null>();
    try {
      const httpRequest = http.createHttp();
      const token = TokenUtil.getInstance().getToken();

      const response = await httpRequest.request(`${BASE_URL}/upload/image`, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': `Bearer ${token}`
        },
        extraData: { url }
      });

      if (typeof response.result === 'string') {
        const parsed = JSON.parse(response.result);
        result.code = parsed.code || 0;
        result.message = parsed.message || '';
        result.data = parsed.data || null;
        result.timestamp = parsed.timestamp || Date.now();
      }

      httpRequest.destroy();
      return result;
    } catch (error) {
      console.error('[UploadApi] deleteImage error:', JSON.stringify(error));
      result.code = -1;
      result.message = '删除失败';
      result.data = null;
      result.timestamp = Date.now();
      return result;
    }
  }
}
