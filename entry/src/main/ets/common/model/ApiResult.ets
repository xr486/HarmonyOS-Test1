export class ApiResult<T> {
  code: number = 0;
  message: string = '';
  data: T | null = null;
  timestamp: number = 0;
}

export class PageResult<T> {
  list: T[] = [];
  total: number = 0;
  pageNum: number = 1;
  pageSize: number = 20;
  totalPages: number = 0;
}
