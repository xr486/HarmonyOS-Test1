import { HttpUtil } from './HttpUtil';
import { ApiResult } from '../model/ApiResult';
import { UserStore } from '../store/UserStore';
import request from '@ohos.request';
import fs from '@ohos.file.fs';

/**
 * 上传结果
 */
export interface UploadResult {
  url: string;
  size: number;
  width: number;
  height: number;
}

/**
 * 文件上传API
 */
export class UploadApi {
  private static readonly BASE_URL = 'https://api.campus-lostandfound.com/api/v1';
  private static readonly UPLOAD_PATH = '/upload/image';
  private static userStore: UserStore = UserStore.getInstance();

  /**
   * 上传图片
   * @param filePath 图片文件路径
   * @param type 用途类型：item=物品图片，avatar=头像
   * @returns 上传结果，包含URL
   */
  static async uploadImage(filePath: string, type: string = 'item'): Promise<ApiResult<UploadResult>> {
    const token = this.userStore.getToken();
    if (!token) {
      return {
        code: 401,
        message: '请先登录',
        data: null,
        timestamp: Date.now()
      };
    }

    try {
      // 使用request模块上传文件
      const uploadConfig: request.UploadConfig = {
        url: `${this.BASE_URL}${this.UPLOAD_PATH}`,
        header: {
          'Authorization': `Bearer ${token}`
        },
        method: 'POST',
        files: [
          {
            filename: 'file',
            name: 'file',
            uri: `internal://cache/${filePath.split('/').pop()}`,
            type: 'image/jpeg'
          }
        ],
        data: [
          {
            name: 'type',
            value: type
          }
        ]
      };

      // 创建上传任务
      const context = getContext(this);
      const uploadTask = await request.uploadFile(context, uploadConfig);

      // 等待上传完成
      return await new Promise<ApiResult<UploadResult>>((resolve, reject) => {
        uploadTask.on('complete', (taskResults: Array<request.TaskResult>) => {
          if (taskResults && taskResults.length > 0) {
            const result = taskResults[0];
            if (result.responseCode === 200) {
              try {
                const data = JSON.parse(result.data as string);
                resolve({
                  code: data.code || 200,
                  message: data.message || '上传成功',
                  data: data.data as UploadResult,
                  timestamp: data.timestamp || Date.now()
                });
              } catch (e) {
                console.error('[UploadApi] parse response error:', JSON.stringify(e));
                resolve({
                  code: -1,
                  message: '响应解析失败',
                  data: null,
                  timestamp: Date.now()
                });
              }
            } else {
              resolve({
                code: result.responseCode,
                message: '上传失败',
                data: null,
                timestamp: Date.now()
              });
            }
          } else {
            resolve({
              code: -1,
              message: '上传失败',
              data: null,
              timestamp: Date.now()
            });
          }
        });

        uploadTask.on('fail', (err: number) => {
          console.error('[UploadApi] upload failed:', err);
          resolve({
            code: err,
            message: '上传失败',
            data: null,
            timestamp: Date.now()
          });
        });
      });

    } catch (e) {
      console.error('[UploadApi] uploadImage error:', JSON.stringify(e));
      return {
        code: -1,
        message: '上传失败，请重试',
        data: null,
        timestamp: Date.now()
      };
    }
  }

  /**
   * 使用HTTP工具类的备用上传方法（简化版）
   * 由于request模块需要沙箱路径，这里提供一个简化版本
   * 实际项目中应该使用ohos.request模块处理文件上传
   * 
   * @param filePath 文件路径
   * @param type 用途类型
   * @returns 上传结果
   */
  static async uploadImageSimple(filePath: string, type: string = 'item'): Promise<ApiResult<UploadResult>> {
    // 这是一个简化版本，实际项目中需要：
    // 1. 使用@ohos.file.picker选择图片
    // 2. 使用@ohos.file.fs复制文件到沙箱目录
    // 3. 使用@ohos.request.uploadFile上传文件
    
    // 由于鸿蒙系统的安全限制，文件上传需要特殊处理
    // 这里返回一个模拟结果用于开发测试
    const token = this.userStore.getToken();
    if (!token) {
      return {
        code: 401,
        message: '请先登录',
        data: null,
        timestamp: Date.now()
      };
    }

    // TODO: 实现真实的文件上传逻辑
    // 实际项目应该调用后端接口返回真实的URL
    console.log('[UploadApi] uploadImageSimple called with:', filePath, type);
    
    return {
      code: 200,
      message: '上传成功（模拟）',
      data: {
        url: `https://cdn.campus-lostandfound.com/items/mock_${Date.now()}.jpg`,
        size: 102400,
        width: 800,
        height: 600
      },
      timestamp: Date.now()
    };
  }

  /**
   * 删除图片
   * @param url 图片URL
   * @returns 删除结果
   */
  static async deleteImage(url: string): Promise<ApiResult<void>> {
    const token = this.userStore.getToken();
    if (!token) {
      return {
        code: 401,
        message: '请先登录',
        data: null,
        timestamp: Date.now()
      };
    }

    try {
      const result = await HttpUtil.request<void>(
        '/upload/image',
        'DELETE',
        { url: url }
      );
      return result;
    } catch (e) {
      console.error('[UploadApi] deleteImage error:', JSON.stringify(e));
      return {
        code: -1,
        message: '删除失败',
        data: null,
        timestamp: Date.now()
      };
    }
  }
}