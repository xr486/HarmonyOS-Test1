import { HttpUtil } from './HttpUtil';
import { ApiResult } from '../model/ApiResult';
import { UserStore } from '../store/UserStore';

/**
 * 上传结果
 */
export class UploadResult {
  url: string = '';
  size: number = 0;
  width: number = 0;
  height: number = 0;
}

/**
 * 文件上传API
 */
export class UploadApi {
  private static readonly BASE_URL = 'http://localhost:8080/api/v1';
  private static readonly UPLOAD_PATH = '/upload/image';

  /**
   * 获取上传Token
   */
  private static getToken(): string {
    const userStore: UserStore = UserStore.getInstance();
    return userStore.getToken();
  }

  /**
   * 上传图片（简化版本）
   * 由于鸿蒙系统的安全限制，文件上传需要特殊处理
   * 这里返回一个模拟结果用于开发测试
   *
   * @param filePath 图片文件路径
   * @param type 用途类型：item=物品图片，avatar=头像
   * @returns 上传结果，包含URL
   */
  static async uploadImageSimple(filePath: string, type: string = 'item'): Promise<ApiResult<UploadResult>> {
    const token: string = UploadApi.getToken();
    if (!token) {
      const result: ApiResult<UploadResult> = new ApiResult<UploadResult>();
      result.code = 401;
      result.message = '请先登录';
      result.data = null;
      result.timestamp = Date.now();
      return result;
    }

    console.info('[UploadApi] uploadImage called with:', filePath, type);

    // 返回模拟结果用于开发测试
    // 实际项目中应该调用后端接口返回真实的URL
    const successResult: ApiResult<UploadResult> = new ApiResult<UploadResult>();
    successResult.code = 200;
    successResult.message = '上传成功（模拟）';
    const data: UploadResult = new UploadResult();
    data.url = `https://cdn.campus-lostandfound.com/items/mock_${Date.now()}.jpg`;
    data.size = 102400;
    data.width = 800;
    data.height = 600;
    successResult.data = data;
    successResult.timestamp = Date.now();
    return successResult;
  }

  /**
   * 上传图片（使用HTTP工具类）
   * 适用于已经上传到服务器的文件URL
   *
   * @param filePath 文件路径
   * @param type 用途类型
   * @returns 上传结果
   */
  static async uploadImageByUrl(filePath: string, type: string = 'item'): Promise<ApiResult<UploadResult>> {
    const token: string = UploadApi.getToken();
    if (!token) {
      const result: ApiResult<UploadResult> = new ApiResult<UploadResult>();
      result.code = 401;
      result.message = '请先登录';
      result.data = null;
      result.timestamp = Date.now();
      return result;
    }

    try {
      const http: HttpUtil = HttpUtil.getInstance();
      const requestData: Record<string, string> = {
        'filePath': filePath,
        'type': type
      };
      const result: ApiResult<UploadResult> = await http.post<UploadResult>(UploadApi.UPLOAD_PATH, requestData, true);
      return result;
    } catch (e) {
      console.error('[UploadApi] uploadImage error:', JSON.stringify(e));
      const errorResult: ApiResult<UploadResult> = new ApiResult<UploadResult>();
      errorResult.code = -1;
      errorResult.message = '上传失败，请重试';
      errorResult.data = null;
      errorResult.timestamp = Date.now();
      return errorResult;
    }
  }

  /**
   * 删除图片
   * @param url 图片URL
   * @returns 删除结果
   */
  static async deleteImage(url: string): Promise<ApiResult<Object>> {
    const token: string = UploadApi.getToken();
    if (!token) {
      const result: ApiResult<Object> = new ApiResult<Object>();
      result.code = 401;
      result.message = '请先登录';
      result.data = null;
      result.timestamp = Date.now();
      return result;
    }

    try {
      const http: HttpUtil = HttpUtil.getInstance();
      const requestData: Record<string, string> = {
        'url': url
      };
      const result: ApiResult<Object> = await http.delete<Object>(UploadApi.UPLOAD_PATH, requestData, true);
      return result;
    } catch (e) {
      console.error('[UploadApi] deleteImage error:', JSON.stringify(e));
      const errorResult: ApiResult<Object> = new ApiResult<Object>();
      errorResult.code = -1;
      errorResult.message = '删除失败';
      errorResult.data = null;
      errorResult.timestamp = Date.now();
      return errorResult;
    }
  }
}
